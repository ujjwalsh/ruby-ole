require 'iconv'
require 'date'

require 'ole/base'

module Ole # :nodoc:
	# FIXME
	module Types
		FROM_UTF16 = Iconv.new 'utf-8', 'utf-16le'
		TO_UTF16   = Iconv.new 'utf-16le', 'utf-8'
		EPOCH = DateTime.parse '1601-01-01'
		# Create a +DateTime+ object from a struct +FILETIME+
		# (http://msdn2.microsoft.com/en-us/library/ms724284.aspx).
		#
		# Converts +str+ to two 32 bit time values, comprising the high and low 32 bits of
		# the 100's of nanoseconds since 1st january 1601 (Epoch).
		def self.load_time str
			low, high = str.unpack 'L2'
			# we ignore these, without even warning about it
			return nil if low == 0 and high == 0
			time = EPOCH + (high * (1 << 32) + low) / 1e7 / 86400 rescue return
			# extra sanity check...
			unless (1800...2100) === time.year
				Log.warn "ignoring unlikely time value #{time.to_s}"
				return nil
			end
			time
		end

		# +time+ should be able to be either a Time, Date, or DateTime.
		def self.save_time time
			# i think i'll convert whatever i get to be a datetime, because of
			# the covered range.
			return 0.chr * 8 unless time
			time = time.send(:to_datetime) if Time === time
			bignum = ((time - Ole::Types::EPOCH) * 86400 * 1e7.to_i)
			high, low = bignum.divmod 1 << 32
			[low, high].pack 'L2'
		end

		# Convert a binary guid into a plain string (will move to proper class later).
		def self.load_guid str
			"{%08x-%04x-%04x-%02x%02x-#{'%02x' * 6}}" % str.unpack('L S S CC C6')
		end
	end
end

