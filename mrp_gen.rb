# Generator for Swiss machine-readable identification documents: passport (TD3) and identiy card (TD1)

CODE = {'<' => 0, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15, 
	'G' => 16, 'H' => 17, 'I' => 18, 'J' => 19, 'K' => 20, 'L' => 21, 'M' => 22, 'N' => 23, 
	'O' => 24, 'P' => 25, 'Q' => 26, 'R' => 27, 'S' => 28, 'T' => 29, 'U' => 30, 'V' => 31, 
	'W' => 32, 'X' => 33, 'Y' => 34, 'Z' => 35 }


def getCode(char)
	begin
		intValue = Integer(char)
		return intValue
	rescue ArgumentError
		return CODE[char.upcase]
	end
end

def fillToArray(text, array, start = 0)
	for i in 0..text.length-1
		array[start+i] = text[i]
	end
	return text.length
end

def calculateCheckDigit(text)
	sum = 0
	for i in 0..text.length-1
		case i%3
		when 0
			weight = 7
		when 1
			weight = 3
		else
			weight = 1
		end
		sum += getCode(text[i])*weight
	end
	return (sum%10).to_s
end

def validSex(sex)
	return (sex == "M" || sex == "F")
end

def validateType(type)
	return (type == "PA" || type == "ID")
end


# country selection not implemented yet
puts "Country: CHE"
coutry = "CHE"

begin
	print "Document type (PA/ID) [ID]: "
	@type = gets.chomp.upcase
	if @type.empty?
		@type = "ID"
	elsif !validateType(@type)
		puts "type invalid"
	end
end until validateType(@type)


print "Surname []: "
surname= gets.chomp.upcase

print "Given name(s) []: "
givenName = gets.chomp.upcase

if (surname.length + givenName.length + 2 >30)
	puts "Surname and Given name must be not more than 28 characters. Exiting."
	exit
end

begin
	print "Sex (M/F) [M]: "
	sex = gets.chomp.upcase
	if sex.empty?
		sex = "M"
	elsif !validSex(sex)
		puts "sex invalid"
	end
end until validSex(sex)

print "Date of birth (YYMMDD) [700720]: "
birth = gets.chomp
if birth.empty? 
	birth="700720"
end

print "Date of expiry (YYMMDD) [251231]: "
expiry = gets.chomp
if expiry.empty?
	expiry = "251231"
end

print "Document no [empty for random]: "
document = gets.chomp.upcase

puts

if @type == "ID"
	line1 = Array.new(30,'<')
	line2 = Array.new(30,'<')
	line3 = Array.new(30,'<')

	if document.empty?
		document="E"+rand(1000000...9999999).to_s
	end

	fillToArray(@type+coutry+document, line1)
	line1[14] = calculateCheckDigit(document)
	fillToArray(birth+calculateCheckDigit(birth)+sex+expiry+calculateCheckDigit(expiry)+coutry, line2)
	line2[29] = calculateCheckDigit((line1[5, 25]+line2[0, 7]+line2[8, 7]+line2[18, 11]).join(""))
	fillToArray(surname+"<<"+givenName.gsub(' ', '<'), line3)

	puts line1.join("")
	puts line2.join("")
	puts line3.join("")

elsif @type == "PA"
	line1 = Array.new(44,'<')
	line2 = Array.new(44,'<')

	if document.empty?
		document="F"+rand(1000000...9999999).to_s
	end

	fillToArray(@type+coutry+surname+"<<"+givenName.gsub(' ', '<'), line1)
	fillToArray(document+"<"+calculateCheckDigit(document)+coutry+birth+calculateCheckDigit(birth)+
		sex+expiry+calculateCheckDigit(expiry), line2)
	line2[43] = calculateCheckDigit((line2[0, 10]+line2[13, 7]+line2[21, 22]).join(""))

	puts line1.join("")
	puts line2.join("")

end