--useful variables
local book_data = {} --used for the metatable
local Book = {} --used to store books
local split --for finding the first split in the file 
local quantity = 0 --for finding the amount of books we have
local file --for making the file
local i = 1 
--local q = 0

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

--loads the file that was saved last
function book_data:load()
	file = io.open("BMS.save", "r")
	
	--makes sure file exists
	if file then
		--understands what books are in the file
		for lines in file:lines() do 
			title, author, year = lines:match("(%b{})(%b{})(%b{})") 
			i = i + 1

			local title1 = string.sub(title, 2, #title-1)
			local author1 = string.sub(author, #author-(#author-2), #author-1)
			local year1 = string.sub(year, #year-4, #year-1)

			table.insert(titles, title1)
			table.insert(authors, author1)
			table.insert(years, year1)

			--adds book to table
			table.insert(self, Book:new(title1, author1, year1))
		end
	else
		io.write("error\nPlease import the book file. Can you do this? Yes or No\n")
		io.flush()
		local answer = io.read()

		if string.lower(answer) == "yes" then
			io.write("Thank you.")
		elseif string.lower(answer) == "no" then
			io.write("\nThis file doesn't exist\nFor help, reach out for help at: railya.farakhova@ht-la.org")
		end
	end 

	--closes the file
	file:close()
end

--checks csv
function book_data:import()
	file = io.open("books.csv", "r")
	
	--makes sure file exists
	if file then
		io.write("")
	else
		io.write("Cannot find file. Make sure you have the csv on your computer\n")
		return "error"
	end 

	--skips over the first line
	file:read("*l")

	for lines in file:lines() do
		split = string.find(lines, ",") --finds first comma
		name = string.find(lines, "%a") --finds first word

		local title = string.sub(lines, name, split-1) --information between first word and first comma
		local author = string.sub(lines, split+1, #lines-7) --information between first comma and second comma
		local year = string.sub(lines, #lines-5, #lines-2) --information between second comma and third comma
		
		table.insert(titles, title)
		table.insert(authors, author)
		table.insert(years, year)

		--adds book to table
		table.insert(self, Book:new(title, author, year))

		--book counter
		quantity = quantity + 1
	end

	--closes the file
	file:close()
	book_data:save()	
	book_data:list()
end

--adds a book to the table and UI
function book_data:add_book(author, year, teacher, status, condition)
	io.input(io.stdin) --to properly call io.read()
	io.write("\nWhat is the book's title?\n")
	io.flush()
	local title = io.read()

	io.write("\nWhat is the book's author?\n")
	io.flush()
	local author = io.read()

	io.write("\nWhen was the book published?\n")
	io.flush()
	local year = io.read()
	
	local count = #titles + 1

	--uses the user info to make a new book in the table
	book_data[count] = Book:new( title, author, year)
	table.insert(titles, title)
	table.insert(authors, author)
	table.insert(years, year)

	io.write("\n"..title.." has been added\n")

	io.write(titles[count].." "..authors[count].." "..years[count])	
end

--stores the books in a seperate file for safe keeping 
--runs and overwrites after each user change in information
function book_data:save()
	local filename = "BMS.save" --new file in the computer
	local book_file = io.open(filename, "w")

	--iterating through the table and saving each entry
	for k = 1, #titles do
		if type(k) == "number" and titles[k] then --checks the variable
			book_file:write("{",titles[k],"}","{",authors[k],"}","{",years[k],"}","\n") 
			--has how many things in our table: title author year
		else

		end
	end 

	--notifies user of the save
	io.write("\nYour books have been saved\n")

	--closes the file
	book_file:close()
end

--retrieves information about a specific book based on user input
function book_data.find_book()
	io.input(io.stdin)
	io.write("How would you like to view the books? By title, author, or index?\n")
	io.flush()
	local answer = io.read()

	--asks what the user knows
	io.write("What is the book's "..answer.."?\n")
	io.flush()
	local search = io.read()
	local location
	local good

	--finds the book based on it's title
	if string.lower(answer) == "title" then
		for m = 1, #titles do
			elements = titles[m]
						
			--finds the book index based on user's input of title
			if elements == search then
				location = m 
				io.write("\nHere is the info: ", authors[location].." "..years[location])
				good = true
			end

		end
		--if nothing is found, notifies the user
		if good == false then
			io.write("\nThis book does not exist.")
		end 
			
	--finds the book based on the author
	elseif string.lower(answer) == "author" then
		for m = 1, #authors do
			elements = authors[m]
						
			--finds the book index based on the user's input of author
			if elements == search then
				location = m 
				io.write("\nHere is the info: ", titles[location].." "..years[location])
				good = true
			end

		end 
		--if book isn't found, notifies the user
		if good == false then
			io.write("\nThis book does not exist.")
		end

	--retrieves all book information if user knows it's index #
	elseif string.lower(answer) == "index" then
		location = search + 0
		io.write("\nHere is the info: ", titles[location].." "..authors[location].." "..years[location])
	end
end

--prints all of the books for the user (UI)
function book_data:list()
		character = "-"
		length = 111 --calculated length needed to fit titles and authors

		--creates a pretty line
		for k = 0, length do
			io.write(character)
		end 
		io.write("\n")

		--titles the 'menu'
		for k = 0, (length/2)-5 do
			io.write(" ")
		end
		io.write("BOOKS\n")

		--creates another pretty line
		for k = 0, length do
			io.write(character)
		end

		--makes a title column
		io.write("\nTitles")
		for p = 0, #titles-5 do
			io.write(" ")
		end

		--makes an author colum
		io.write("Authors")

		--prints out info from the amount of elements in the table (quantity)
		for m = 1, #titles do
			
			--moves information down if it's over 43 characters 
			if #titles[m] > 43 then
				local split = string.sub(titles[m], 1, 43)
				local split2 = string.sub(titles[m], 44, #titles[m])
				io.write("\n"..split.."-")
				for n = 1, #titles+1-#split do
					io.write(".")
				end
				io.write(authors[m].."\n-"..split2)
				for n = 1, #titles+1-#split2 do
					io.write(".")
				end
			else
				io.write("\n",titles[m])

				--maintains the space between titles and authors
				for r = 1, #titles+2- #titles[m] do
					io.write(".")
				end 

				--moves information down if it's over 50 characters
				if #authors[m] > 42 then
					local split = string.sub(authors[m], 1, 42)
					local split2 = string.sub(authors[m], 43, 82)

					io.write(split.."-\n")
					for k = 1, 63 do
						io.write(".")
					end
					io.write("-"..split2)

					if #authors[m] > 82 then
						split3 = string.sub(authors[m], 83, 122)
						io.write("-\n")
						for k = 1, 63 do
							io.write(".")
						end
						io.write("-"..split3)

						if #authors[m] > 122 then
							split4 = string.sub(authors[m], 123, 162)
							io.write("-\n")
							for k = 1, 63 do
								io.write(".")
							end
							io.write("-"..split4)
						end
					end
				else
					io.write(authors[m])
				end
			end 
		end
		--creates 2 pretty lines
		io.write("\n")
		for k = 0, length do
			io.write(character)
		end 
		io.write("\n")
		for k = 0, length do
			io.write(character)
		end 
end 
	
--lists books based on title or author with indexes
function book_data:read()
	io.input(io.stdin)
	io.write("How would you like your books listed? By title or author?\n")
	io.flush()
	local answer = io.read()

	--finds all titles
	if string.lower(answer) == "title" then
		for m = 1, #titles do
			io.write("\n"..m.." "..titles[m])
		end 
	--finds all authors
	elseif string.lower(answer) == "author" then
		for m = 1, #authors do
			io.write("\n"..m.." "..authors[m])
		end
	end
end

--removes a book from the table
function book_data.delete_book()
	io.write("\nWhich book would you like to remove? Provide the index\n") 
	io.flush()
	local digit = io.read("*number")

	--removes the book specified by user
	table.remove(titles, digit)
	table.remove(authors, digit)
	table.remove(years, digit)
	--returns the new book in that location
	io.write("\nNow book " ..digit.. " is: \n"..titles[digit].." "..authors[digit].." "..years[digit])
end
	
function book_data.update_book() 
	io.input(io.stdin)
	io.write("\nFirst, let's find the book. How would you like to search? By title or author?\n")
	io.flush()
	local answer = io.read()

	io.write("\nWhat is the book's "..answer.."?\n")
	io.flush()
	local search = io.read()
	local location

	--finds the book based on title
	if string.lower(answer) == "title" then
		for m = 1, #titles do
			local elements = titles[m]
						
			if elements == search then
				location = m 
			end
		end 

		--error message if title doesn't exist
		if titles[location] == nil then
			return io.write("\nThis book does not exist")
		else

			io.write("\nWhat would you like to change? Title, author, year, or checkout status?\n")
			io.flush()
			local change = io.read()

			--changes an aspect of the book
			if string.lower(change) == "title" then
				io.write("\nWhat would you like to change the title to?\n")
				io.flush()
				new_title = io.read()
				titles[location] = new_title
			elseif string.lower(change) == "author" then
				io.write("\nWhat would you like to change the author to?\n")
				io.flush()
				new_author = io.read()
				authors[location] = new_author
			elseif string.lower(change) == "year" then
				io.write("\nWhat would you like to change the year to?\n")
				io.flush()
				new_year = io.read()
				years[location] = new_year
			elseif string.lower(change) == "checkout status" then
				io.write("\nHas the book been checked out or returned?\n")
				io.flush()
				local new_status = io.read()

				if string.lower(new_status) == "checked out" then
					book_data[location].status = true
				elseif string.lower(new_status) == "returned" then
					book_data[location].status = false
				else 
					--if user puts a different input
					io.write("\nI didn't understand.")
				end
			end
		end

	--shows the user the change
	io.write("\nYour book is now: ".." "..titles[location].." "..authors[location].." "..years[location])
	
	--finds the book based on author
	elseif string.lower(answer) == "author" then
		for m = 1, #authors do
			local elements = authors[m]
						
			if elements == search then
				location = m 
			end

		end

		--gives a error if can't find author
		if authors[location] == nil then
			return io.write("\nThis book does not exist")
		else

			io.write("\nWhat would you like to change? Title, author, or year?\n")
			io.flush()
			local change = io.read()

			--changes an aspect of the book
			if string.lower(change) == "title" then
				io.write("\nWhat would you like to change the title to?\n")
				io.flush()
				new_title = io.read()
				titles[location] = new_title
			elseif string.lower(change) == "author" then
				io.write("What would you like to change the author to?\n")
				io.flush()
				new_author = io.read()
				authors[location] = new_author
			elseif string.lower(change) == "year" then
				io.write("What would you like to change the year to?\n")
				io.flush()
				new_year = io.read()
				years[location] = new_year
			elseif string.lower(change) == "checkout status" then
				io.write("Has the book been checked out or returned?\n")
				io.flush()
				new_status = io.read()

				if string.lower(new_status) == "checked out" then
					book_data[location].status = true
				elseif string.lower(new_status) == "returned" then
					book_data[location].status = false
				else 
					--if user writes a different input
					io.write("I didn't understand.")
				end
			end  

		end 
		--returns the changed book
		io.write("Your book is now: ".." "..titles[location].." "..authors[location].." "..years[location])
	end 
end 

setmetatable(Book, book_data)

--runs all of the functions based on user
function execute()
		--asks user what they want to do
		local question = "\n\n What would you like to do? You can: \n read catalog \n add books \n find books \n update \n delete \n import \n"
		io.write(question)
		io.flush()

		--grabs input from user
		local user = ""
		user = io.read()

		--user interaction with the program
		if string.lower(user) == "add books" then
			book_data.add_book()
			book_data.save()

		elseif string.lower(user) == "find books" then
			book_data.find_book()

		elseif string.lower(user) == "read catalog" then
			book_data.read()

		elseif string.lower(user) == "delete" then
			book_data.delete_book()
			book_data.save()

		elseif string.lower(user) == "update" then
			book_data.update_book()
			book_data.save()

		elseif string.lower(user) == "import" then
			local x=book_data:load()
			if x == "error" then
				io.write("Please import the book file. Can you do this? Yes or No\n")
				io.flush()
				local answer = io.read()

				if string.lower(answer) == "yes" then
					io.write("Thank you.\n")
					book_data:import()
					
				elseif string.lower(answer) == "no" then
					io.write("\nThis file doesn't exist\nFor help, reach out for help at: railya.farakhova@ht-la.org")
				end
			else
				book_data:load() 
			end	
		end

		io.write("\nWould you like to do something else? Yes or No?\n")
		io.flush()
		local answer = io.read()

		if string.lower(answer) == "yes" then 
			execute()
		elseif string.lower(answer) == "no" then
			io.write("\nUnderstood. Have a good day.")
		else
			io.write("\nI didn't understand. Good bye.")
		end
end 

book_data:load()
book_data:list()
execute()

io.write("\nPress CTRL+B to run code again")
