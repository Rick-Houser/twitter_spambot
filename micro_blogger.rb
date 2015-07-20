require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
  	if message.length <= 140
  		@client.update(message)
  	else
  		puts "The message length is 140 characters max."
  	end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
			if !following?(target)
				puts "You aren't following this person and cannot send your message."
			end
    tweet(message)
  end

  def screen_names
    @client.followers.map { |follower| @client.user(follower).screen_name }
  end

  def following?(user)
    screen_names.include?(user)
  end

  def followers_list
    screen_names = []
    @client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end


  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    new_url = bitly.shorten('http://jumpstartlab.com/courses/').short_url
    puts "Shortening this URL: #{original_url}"
    new_url
  end

  def run
  	puts "Welcome to the JSL Twitter Client."
	  command = ""
	  while command != "q"
	  	printf "Enter command: "
	  	input = gets.chomp
	  	parts = input.split(" ")
	  	command = parts[0]
	  	case command
		  	when 'q' 
		  		puts "Goodbye!"
		  	when 't'
		  		tweet(parts[1..-1].join(" "))
		  	when 'dm'
		  		dm(parts[1], parts[2..-1].join(" "))
		  	when 'spam'
		  		spam_my_followers(parts[1..-1].join(" "))
		  	when 's'
		  		shorten(parts[1])
		  	when 'turl'
		  		tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
		  	else
		  		puts "Sorry, I don't know how to #{command}"
		  end
		end
  end
end

blogger = MicroBlogger.new
blogger.run
