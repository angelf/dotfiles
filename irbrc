#!/usr/bin/ruby
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

IRB.conf[:PROMPT_MODE] = :SIMPLE

%w[rubygems looksee/shortcuts wirble hirb].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

# start wirble (with color)
Wirble.init
Wirble.colorize

Hirb::View.enable
   
class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

require 'tempfile'
 
def history(how_many = 50)
  history_size = Readline::HISTORY.size
  # no lines, get out of here
  puts "No history" and return if history_size == 0
  start_index = 0
  # not enough lines, only show what we have
  if history_size <= how_many
    how_many  = history_size - 1
    end_index = how_many
  else
    end_index = history_size - 1 # -1 to adjust for array offset
    start_index = end_index - how_many 
  end
  start_index.upto(end_index) {|i| print_line i}
end
alias :h  :history

# -2 because -1 is ourself
def history_do(lines = (Readline::HISTORY.size - 2))
  irb_eval lines
end 
alias :h! :history_do

def history_write(filename, lines)
  file = File.open(filename, 'w')
  get_lines(lines).each do |l|
    file << "#{l}\n"
  end
  file.close
end

# TODO: history_write should go to a file, or the clipboard, or a file which opens in an application
def history_to_vi
  handling_jruby_bug do
    file = Tempfile.new("irb_tempfile")
    get_lines(0..(Readline::HISTORY.size - 1)).each do |line|
      file << "#{line}\n"
    end
    file.close
    system("vim #{file.path}")
  end
end
alias :hvi :history_to_vi

private
def get_line(line_number)
  Readline::HISTORY[line_number] rescue ""
end

def get_lines(lines = [])
  return [get_line(lines)] if lines.is_a? Fixnum
  out = []
  lines = lines.to_a if lines.is_a? Range
  lines.each do |l|
    out << Readline::HISTORY[l]
  end
  out
end

def print_line(line_number, show_line_numbers = true)
  print line_number.to_s + ": " if show_line_numbers
  puts get_line(line_number)
end

def irb_eval(lines)
  to_eval = get_lines(lines)
  to_eval.each {|l| Readline::HISTORY << l}
  eval to_eval.join("\n")
end

def paste
  `pbpaste`
end

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']
