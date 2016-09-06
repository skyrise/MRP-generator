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
	return (sex == "M" || sex == "F" || sex == "<")
end

def validateDocType(docType)
	return (docType == "TD1" || docType == "TD3")
end


begin
	print "What type of document would you like to create? TD3 (passport) or TD1 (identity / passport card)? (TD1|TD3): "
	@docType = gets.chomp.upcase
	if !validateDocType(@docType)
		puts "Please enter TD1 or TD3."
	end
end until validateDocType(@docType)

 
print "Country code (ISO 3166-1 alpha-3) [CHE]:"
country = gets.chomp.upcase
if country.empty?
	country = "CHE"
end
country = country.ljust(3, '<')[0...3]

if country == "CHE"
	if @docType == "TD1" 
		@type = "ID"
	else
		@type = "PA"
	end
else
	print "Document type [<]: "
	_type = gets.chomp.upcase
	if _type.empty?
		_type = "<"
	end

	if @docType == "TD1" 
		@type = "I"+_type[0]
	else
		@type = "P"+_type[0]
	end
end

print "Surname []: "
surname= gets.chomp.upcase

print "Given name(s) []: "
givenName = gets.chomp.upcase

if (@docType == "TD1" && surname.length + givenName.length + 2 >30)
	puts "Surname and Given name must be not more than 28 characters. Exiting."
	exit
elsif (@docType == "TD3" && surname.length + givenName.length + 2 >39)
	puts "Surname and Given name must be not more than 37 characters. Exiting."
	exit
end
	

begin
	print "Sex (M/F/<) [<]: "
	sex = gets.chomp.upcase
	if sex.empty?
		sex = "<"
	elsif !validSex(sex)
		puts "sex invalid"
	end
end until validSex(sex)

begin
	print "Date of birth (YYMMDD) [700720]: "
	birth = gets.chomp[0...6]
	if birth.empty? 
		birth="700720"
	end
end until (birth.length == 6)


begin
	print "Date of expiry (YYMMDD) [251231]: "
	expiry = gets.chomp[0...6]
	if expiry.empty?
		expiry = "251231"
	end
end until (birth.length == 6)

print "Document no. [empty for random]: "
document = gets.chomp[0...9].upcase
if document.empty?
	if country == "CHE"
		if @docType == "TD1" 
			document="E"+rand(1000000...9999999).to_s
		elsif @docType == "TD3" 
			document="F"+rand(1000000...9999999).to_s
		end
	else
		document = rand(100000000...999999999).to_s
	end
end
document = document.ljust(9, '<')

puts

if @docType == "TD1"
	line1 = Array.new(30,'<')
	line2 = Array.new(30,'<')
	line3 = Array.new(30,'<')

	print "Optional (line 1): "
	optional1=gets.chomp[0...14].upcase
	if !optional1.empty?
		optional1 = optional1.ljust(15, '<').gsub(' ', '<')
		fillToArray(optional1, line1, 15)
	end

	print "Optional (line 2): "
	optional2=gets.chomp[0...10].upcase
	if !optional2.empty?
		optional2 = optional2.ljust(11, '<').gsub(' ', '<')
		fillToArray(optional2, line2, 18)
	end
	
	fillToArray(@type+country+document, line1)
	line1[14] = calculateCheckDigit(document)
	fillToArray(birth+calculateCheckDigit(birth)+sex+expiry+calculateCheckDigit(expiry)+country, line2)
	line2[29] = calculateCheckDigit((line1[5, 25]+line2[0, 7]+line2[8, 7]+line2[18, 11]).join(""))
	fillToArray(surname+"<<"+givenName.gsub(' ', '<'), line3)

	puts line1.join("")
	puts line2.join("")
	puts line3.join("")

elsif @docType == "TD3"
	line1 = Array.new(44,'<')
	line2 = Array.new(44,'<')

	print "Optional: "
	optional1=gets.chomp[0...13].upcase
	if !optional1.empty?
		optional1 = optional1.ljust(14, '<').gsub(' ', '<')
		fillToArray(optional1, line2, 28)
		if (optional1 != "<<<<<<<<<<<<<<")
			line2[42] = calculateCheckDigit(optional1)
		end
	end


	fillToArray(@type+country+surname+"<<"+givenName.gsub(' ', '<'), line1)
	fillToArray(document+calculateCheckDigit(document)+country+birth+calculateCheckDigit(birth)+
		sex+expiry+calculateCheckDigit(expiry), line2)
	line2[43] = calculateCheckDigit((line2[0, 10]+line2[13, 7]+line2[21, 22]).join(""))

	puts line1.join("")
	puts line2.join("")

end
