# frozen_string_literal: true

module Idnx
  module Ruby
    module_function

    def lookup(hostname)
      Punycode.encode_hostname(hostname)
    end

    # -*- coding: utf-8 -*-
    #--
    # punycode.rb - PunyCode encoder for the Domain Name library
    #
    # Copyright (C) 2011-2017 Akinori MUSHA, All rights reserved.
    #
    # Ported from puny.c, a part of VeriSign XCode (encode/decode) IDN
    # Library.
    #
    # Copyright (C) 2000-2002 Verisign Inc., All rights reserved.
    #
    # Redistribution and use in source and binary forms, with or
    # without modification, are permitted provided that the following
    # conditions are met:
    #
    #  1) Redistributions of source code must retain the above copyright
    #     notice, this list of conditions and the following disclaimer.
    #
    #  2) Redistributions in binary form must reproduce the above copyright
    #     notice, this list of conditions and the following disclaimer in
    #     the documentation and/or other materials provided with the
    #     distribution.
    #
    #  3) Neither the name of the VeriSign Inc. nor the names of its
    #     contributors may be used to endorse or promote products derived
    #     from this software without specific prior written permission.
    #
    # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    # "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    # LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    # FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    # COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    # INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    # BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
    # OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
    # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    # LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    # ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    # POSSIBILITY OF SUCH DAMAGE.
    #
    # This software is licensed under the BSD open source license. For more
    # information visit www.opensource.org.
    #
    # Authors:
    #  John Colosi (VeriSign)
    #  Srikanth Veeramachaneni (VeriSign)
    #  Nagesh Chigurupati (Verisign)
    #  Praveen Srinivasan(Verisign)
    #++
    module Punycode
      BASE = 36
      TMIN = 1
      TMAX = 26
      SKEW = 38
      DAMP = 700
      INITIAL_BIAS = 72
      INITIAL_N = 0x80
      DELIMITER = "-"

      MAXINT = (1 << 32) - 1

      LOBASE = BASE - TMIN
      CUTOFF = LOBASE * TMAX / 2

      RE_NONBASIC = /[^\x00-\x7f]/.freeze

      # Returns the numeric value of a basic code point (for use in
      # representing integers) in the range 0 to base-1, or nil if cp
      # is does not represent a value.
      DECODE_DIGIT = begin
        map = {} #: Hash[Integer, Integer]
        # ASCII A..Z map to 0..25
        # ASCII a..z map to 0..25
        (0..25).each { |i| map[65 + i] = map[97 + i] = i }
        # ASCII 0..9 map to 26..35
        (26..35).each { |i| map[22 + i] = i }
        map
      end

      # Returns the basic code point whose value (when used for
      # representing integers) is d, which must be in the range 0 to
      # BASE-1.  The lowercase form is used unless flag is true, in
      # which case the uppercase form is used.  The behavior is
      # undefined if flag is nonzero and digit d has no uppercase
      # form.
      ENCODE_DIGIT = proc { |d, flag|
        (d + 22 + (d < 26 ? 75 : 0) - (flag ? (1 << 5) : 0)).chr
        #  0..25 map to ASCII a..z or A..Z
        # 26..35 map to ASCII 0..9
      }

      DOT = "."
      PREFIX = "xn--"

      # Most errors we raise are basically kind of ArgumentError.
      class ArgumentError < ::ArgumentError; end
      class BufferOverflowError < ArgumentError; end

      module_function

      # Encode a +string+ in Punycode
      def encode(string)
        input = string.unpack("U*") #: Array[Integer]
        output = +""

        # Initialize the state
        n = INITIAL_N
        delta = 0
        bias = INITIAL_BIAS

        # Handle the basic code points
        input.each { |cp| output << cp.chr if cp < 0x80 }

        h = b = output.length

        # h is the number of code points that have been handled, b is the
        # number of basic code points, and out is the number of characters
        # that have been output.

        output << DELIMITER if b > 0

        # Main encoding loop

        while h < input.length
          # All non-basic code points < n have been handled already.  Find
          # the next larger one

          m = MAXINT
          input.each do |cp|
            m = cp if (n...m) === cp
          end

          # Increase delta enough to advance the decoder's <n,i> state to
          # <m,0>, but guard against overflow

          delta += (m - n) * (h + 1)
          raise BufferOverflowError if delta > MAXINT

          n = m

          input.each do |cp|
            # AMC-ACE-Z can use this simplified version instead
            if cp < n
              delta += 1
              raise BufferOverflowError if delta > MAXINT
            elsif cp == n
              # Represent delta as a generalized variable-length integer
              q = delta
              k = BASE
              loop do
                t = k <= bias ? TMIN : k - bias >= TMAX ? TMAX : k - bias
                break if q < t

                q, r = (q - t).divmod(BASE - t)
                output << ENCODE_DIGIT[t + r, false]
                k += BASE
              end

              output << ENCODE_DIGIT[q, false]

              # Adapt the bias
              delta = h == b ? delta / DAMP : delta >> 1
              delta += delta / (h + 1)
              bias = 0
              while delta > CUTOFF
                delta /= LOBASE
                bias += BASE
              end
              bias += (LOBASE + 1) * delta / (delta + SKEW)

              delta = 0
              h += 1
            end
          end

          delta += 1
          n += 1
        end

        output
      end

      # Encode a hostname using IDN/Punycode algorithms
      def encode_hostname(hostname)
        hostname.match(RE_NONBASIC) || (return hostname)

        hostname.split(DOT).map do |name|
          if name.match(RE_NONBASIC)
            PREFIX + encode(name)
          else
            name
          end
        end.join(DOT)
      end
    end
  end
end