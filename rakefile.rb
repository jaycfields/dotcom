require 'fileutils'
require 'erb'

task :publish => :build do
  require 'net/ftp'

  Net::FTP.open('ftp.jayfields.com') do |ftp|
    Dir['build/*'].each do |chapter|
      ftp.passive = true
      if chapter =~ /jpg$/
        puts "attempting to publish binary #{chapter}"
        ftp.putbinaryfile chapter
      else
        puts "attempting to publish text #{chapter}"
        ftp.puttextfile chapter
      end
      puts "published #{chapter}"
    end
    ftp.close
  end
end

class Content
  class << self
    attr_accessor :source, :page
  end
  def self.content
    File.read(source)
  end
  def self.page
    case @page 
      when "Index" then "Home"
      when "Oss" then "Open Source"
      else @page
    end
  end
end
  
task :build do
  FileUtils.rm_rf 'build' if File.exists?('build')
  FileUtils.mkdir 'build'
  Dir['./*.txt'].each do |txt|
    File.open("build/#{File.basename(txt, ".txt")}.htm", "w") do |file|
      erb_template = ERB.new File.read("naturalist/index.html")
      Content.source = txt
      Content.page = File.basename(txt, ".txt").capitalize
      file << erb_template.result(Content.send(:binding))
    end
  end
  Dir['naturalist/css/*'].each do |file|
    FileUtils.cp file, "build"
  end
  Dir['naturalist/img/*'].each do |file|
    FileUtils.cp file, "build"
  end
end