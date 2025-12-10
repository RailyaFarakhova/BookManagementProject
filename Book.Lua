--useful variables
local book_data = {} --used for the metatable
local Book = {} --used to store books
local comma --for finding the first comma in the file 
local quantity = 0 --for finding the amount of books we have
local file --for making the file
local i = 1

--describes a book class
Book = {
	title = {},
 	author = {},
 	year = {}, 
 	teacher = "", 
 	status = false, 
 	condition = ""
 }

--creates a way to store this into the table seperated by key
local titles = Book.title
local authors = Book.author
local years = Book.year

file = io.open("BOOK NAMES SHEET - Mr. Wilkinson.csv", "r") --opens the file

--makes sure file exists
if file then
	print(" ")
else 
	print("The file doesn't exist.")
end 

--skips over the first line
file:read("*l")

--places our books into the table

--helps make a new book for the add_book function
function Book:new(title, author, year)
	bd = {}
	setmetatable(bd, self)
	self.__index = self
	self.title = title or "HTLA Chronicles"
	self.author = author or "John Smith"
	self.year = year or "1900"
	self.teacher = "Mr. Wilkinson"
	self.status = false
	self.condition = "Good"

	return bd
end 

for lines in file:lines() do

	comma = string.find(lines, ",") --finds first comma
	name = string.find(lines, "%a") --finds first word

	local title = string.sub(lines, name, comma-1) --information between first word and first comma
	local author = string.sub(lines, comma+1, #lines-7) --information between first comma and second comma
	local year = string.sub(lines, #lines-5, #lines-2) --information between second comma and third comma

	--adds the values to corresponding locations
	table.insert(titles, title)
	table.insert(authors, author)
	table.insert(years, year)

	book_data[i] = Book:new(title, author, year)
	i = i + 1
	
	quantity = quantity + 1

end 

function book_data:load()
	local filename = "teacherbooks.txt"
	local book_file = io.open(filename, "r")

	for i = 1, #self do
		if type(i) == "number" then
			table.remove(self, 1)
		end
	end
	for line in book_file:lines() do 
		title, author, year = line:match("(%b{})(%b{})(%b{})") 
		--capture groups, segment the stuff inside of the match to be differnet pieces
		--will return 3 seperate pieces, the a b c are the variables the match pieces
		-- are assigned to
		title = title:sub(2, #title-1)
		author = author:sub(2, #author-1)
		year = year:sub(2, #year-1)

		table.insert(self, Book:new(title, author, year))
	end

	book_file:close()
end

function book_data:add_book(author, year, teacher, status, condition)
	io.input(io.stdin) --to properly call io.read()
	print("\nWhat is the book's title?")

	local title = io.read()

	print("\nWhat is the book's author?")
	local author = io.read()

	print("\nWhen was the book published?")
	local year = io.read()
	quantity = quantity + 1 --determines the location of new book

	book_data[quantity] = Book:new(book_data[quantity], title, author, year)
		print("\n"..title.." has been added")
		table.insert(titles, title)
		table.insert(authors, author)
		table.insert(years, year)

		print(titles[quantity], authors[quantity], years[quantity])
			
end

function book_data:save()
	local filename = "teacherbooks.txt" --new file in your computer
	local book_file = io.open(filename, "w")

	--iterating through the table and saving each entry
	for k = 1, quantity do
		if type(k) == "number" then --checks the variable
			book_file:write("{",titles[k],"}","{",authors[k],"}","{",years[k],"}","\n") --this is the method io.write
			--has how many things in our table: title author year

		end
	end 

	print("Your books have been saved")

	book_file:close()
end

function book_data.find_book()
	io.input(io.stdin)
	print("How would you like to view the books? By title, author, or index?")
	local answer = io.read()

	print("What is the book's "..answer.."?")
	local search = io.read()
	local location
	local good

	if answer == "title" then
		for m = 1, #titles do
			elements = titles[m]
						
			--finds the index of the book the user wants based on title
			if elements == search then
				location = m 
				print("Here is the info: ", authors[location], years[location])
				good = true
			end

		end
		if good == false then
			print("This book does not exist.")
		end 
			
	elseif answer == "author" then
		for m = 1, #authors do
			elements = authors[m]
						
			--finds the index of the book the user wants based on author
			if elements == search then
				location = m 
				print("Here is the info: ", titles[location], years[location])
				good = true
			end

		end 
		if good == false then
			print("This book does not exist.")
		end

	elseif answer == "index" then
		location = search + 0
		print("Here is the info: ", titles[location], authors[location], years[location])
	end
end

function book_data:list()
	character = "-"
	length = ((#titles) + (#authors) - 10)*2 + 1

	for k = 0, length do
		io.write(character)
	end 
	io.write("\nTitle")

	for p = 0, #titles-20 do
		io.write(" ")
	end
	io.write("Authors")

	for p = 0, #authors-4 do
		io.write(" ")
	end

	for m = 1, quantity do
		
		if m == 32 then
			io.write("\nEruption in the Canyon 212 Days & Nights \n with the Genius of Eddie Van Halen             Andrew Bennett")
		else
			io.write("\n",titles[m])

			for r = 1, (#titles-13 - #titles[m]) do
				io.write(" ")
			end 

			if m == 23 then
				io.write("Alfred David, et al")
			elseif m == 31 then
				io.write("William E. Cain, et al")
			else
				io.write(authors[m])
			end
		end 

	end
		io.write("\n")
		for k = 0, length do
			io.write(character)
		end 

end 
	
function book_data:read()
	io.input(io.stdin)
	print("How would you like your books listed? By title or author?")
	answer = io.read()

	if answer == "title" then
		for i = 1, #titles do
			 print(i, titles[i])
		end 
	elseif answer == "author" then
		for i = 1, #authors do
			print(i, authors[i])
		end
end

function book_data.delete_book(digit)
	table.remove(titles, digit)
	table.remove(authors, digit)
	table.remove(years, digit)
	--returns the new book in that location
	print("Now book " ..digit.. " is: \n "..titles[digit], authors[digit], years[digit])
end

	
function book_data.update_book() 
	io.input(io.stdin)
	print("First, let's find the book. How would you like to search? By title or author?")
	local answer = io.read()
	print("What is the book's "..answer.."?")
	local search = io.read()
	local location
	--finds the book based on title
	if answer == "title" then
		for m = 1, #titles do
			local elements = titles[m]
						
			if elements == search then
				location = m 
			end

		end 
		print("Your book is: ", titles[location], authors[location], years[location])

		if titles[location] == nil then
			return print("This book does not exist")
		else

			print("What would you like to change? Title, author, year, or checkout status?")
			change = io.read()
			--changes an aspect of the book
			if change == "title" then
				print("What would you like to change the title to?")
				new_title = io.read()
				titles[location] = new_title
			elseif change == "author" then
				print("What would you like to change the author to?")
				new_author = io.read()
				authors[location] = new_author
			elseif change == "year" then
				print("What would you like to change the year to?")
				new_year = io.read()
				years[location] = new_year
			elseif change == "checkout status" then
				print("Has the book been checked out or returned?")
				new_status = io.read()
				if new_status == "checked out" then
					book_data[location].status = true
				elseif new_status == "returned" then
					book_data[location].status = false
				else 
					print("I didn't understand.")
				end
			end
		end

	--shows the user the change
	print("Your book is now: ", titles[location], authors[location], years[location])
	--finds the book based on author
	elseif answer == "author" then
		for m = 1, #authors do
			for m = 1, #authors do
				local elements = authors[m]
						
				if elements == search then
					location = m 
				end

			end 
			print("Your book is: ", titles[location], authors[location], years[location])

			if titles[location] == nil then
				return print("This book does not exist")
			else

				print("What would you like to change? Title, author, or year?")
				change = io.read()

				--changes an aspect of the book
				if change == "title" then
					print("What would you like to change the title to?")
					new_title = io.read()
					titles[location] = new_title
				elseif change == "author" then
					print("What would you like to change the author to?")
					new_author = io.read()
					authors[location] = new_author
				elseif change == "year" then
					print("What would you like to change the year to?")
					new_year = io.read()
					years[location] = new_year
				elseif change == "checkout status" then
					print("Has the book been checked out or returned?")
					new_status = io.read()

					if new_status == "checked out" then
						book_data[location].status = true
					elseif new_status == "returned" then
						book_data[location].status = false
					else 
						print("I didn't understand.")
					end
				end  

			end 
			--returns the changed book
			print("Your book is now: ", titles[location], authors[location], years[location], book_data[location].status)
		end
	end 
end 

setmetatable(Book, book_data)

function execute()

	book_data.list()

	--asks user what they want to do
	local question = "\n\n What would you like to do? You can: \n read catalog \n add books \n find books \n update \n delete"
	print(question)

	--grabs input from user
	local user = ""
	user = io.read()

	--user interaction with the program
	if user == "add books" then
		book_data.add_book()
		book_data.save()

	elseif user == "find books" then

		book_data.find_book()

	elseif user == "read catalog" then

		book_data.read()

	elseif user == "delete" then

		io.input(io.stdin)
		print("Which book would you like to remove? Provide the index") 
		book = io.read("*number")
		book_data.delete_book(book)
		book_data.save()

	elseif user == "update" then

		book_data.update_book()
		book_data.save()

	end

	print("Would you like to do something else? Yes or No?")
	answer = io.read()

	if answer == "Yes" then 
		execute()
	elseif answer == "No" then
		print("Understood. Have a good day.")
	else
		print("I didn't understand. Good bye.")
	end
end 

book_data:load()
execute()

print("Press CTRL+B to run code again")
