require 'shoes'

class DiceMediator
	# should be array of sides of dice
	attr_reader :dice, :toggler
	def initialize dice
		@dice = dice.map { |d| Dice.new self, d }
		
		tog = total_faceup % 2 == 0
		
		@toggler = Toggler.new self, tog
	end
	
	def dice_count
		count = 0
		@dice.each { |d| count += d.faceup }
		count
	end
	
	def total_faceup
		@dice.map{ |d| d.faceup }.inject { |sum, d| sum+d } 
	end
	
	def total_sides
		@dice.map{ |d| d.num_sides }.inject { |sum, d| sum+d }
	end
	def send caller
		puts "Sent!"
		if caller.is_a? Dice
			@toggler.receive if total_faceup % 2 == 0
		elsif caller.is_a? Toggler
			@toggler.toggle
		elsif caller.is_a? Integer
			puts "Test"
			@dice[caller].receive
		end
	end
end

class Colleague
	attr_reader :mediator
	def initialize mediator
		@mediator = mediator
	end
	
	def send
		@mediator.send self
	end
end


class Dice < Colleague
	attr_reader :faceup, :num_sides
	
	def initialize mediator, num_sides = 6
		@num_sides = num_sides
		@faceup = rand(@num_sides)+1
		super mediator
	end
	
	def roll
		@faceup = rand(num_sides)+1
	end
	
	def receive
		roll
		send
	end
end


class Toggler < Colleague
	attr_reader :tog
	#@tog = false
	
	def initialize mediator, tog
		@tog = tog
		super mediator
	end
	
	def toggle
		@tog = !@tog
	end
	
	def receive
		toggle
	end
end



Shoes.app do
=begin	
	stack do
		@foobar = para "foo"
		check = true
		tog = { true => "foo", false => "bar" }
		@btn = button 'Change!' do |btn|
			check = !check
			old = @btn
			new_style = old.style.dup
			txt = tog[check]
			old.parent.before(old) do
				@btn = button txt, new_style
			end
			old.remove #This messes up the click events on Windows.
		end
	end
=end	
	#stack do
		@btn = Array.new(dm.dice.length)
		@dm = DiceMediator.new [6,6,12,4,20,8]
		
		
		@dm.dice.length.times do |i|
			@btn[i] = button "#{@dm.dice[i].faceup}/#{@dm.dice[i].num_sides}" do 
				#alert "Clicked!"
				@dm.send i
				old = @btn[i]
				new_style = old.style.dup
				txt = "#{@dm.dice[i].faceup}/#{@dm.dice[i].num_sides}"
				old.parent.before(old) do
					@btn[i] = button txt, new_style
				end
				old.remove #This messes up the click events on Windows.
				@tot.replace "Total: #{@dm.total_faceup}/#{@dm.total_sides}"
				@tg.replace "Toggler: #{@dm.toggler.tog}"
			end
		end
		
		stack do
			@tot = para "Total: #{@dm.total_faceup}/#{@dm.total_sides}"
			@tg = para "Toggler: #{@dm.toggler.tog}"
		end
	#end
	
	
	
end