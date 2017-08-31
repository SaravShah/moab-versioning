require 'spec_helper'

# Unit tests for class {Moab::FileInstance}
describe 'Moab::FileInstance' do

  describe '=========================== CONSTRUCTOR ===========================' do

    # Unit test for constructor: {Moab::FileInstance#initialize}
    # Which returns an instance of: [Moab::FileInstance]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should
    #   correspond to attributes declared using HappyMapper syntax
    specify 'Moab::FileInstance#initialize' do

      # test initialization with required parameters (if any)
      opts = {}
      file_instance = Moab::FileInstance.new(opts)
      expect(file_instance).to be_instance_of(Moab::FileInstance)

      # test initialization with options hash
      opts = Hash.new
      opts[:path] = @temp.join('path').to_s
      opts[:datetime] = "Apr 18 21:51:31 UTC 2012"
      file_instance = Moab::FileInstance.new(opts)
      expect(file_instance.path).to eq(opts[:path])
      expect(file_instance.datetime).to eq("2012-04-18T21:51:31Z")
       
      # def initialize(opts={})
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @file_instance = Moab::FileInstance.new(opts)
    end
    
    # Unit test for attribute: {Moab::FileInstance#path}
    # Which stores: [String] \@ = The id is the filename path, relative to the file group's base directory
    specify 'Moab::FileInstance#path' do
      value = 'Test path'
      @file_instance.path= value
      expect(@file_instance.path).to eq(value)
       
      # attribute :path, String, :key => true
    end
    
    # Unit test for attribute: {Moab::FileInstance#datetime}
    # Which stores: [Time] \@ = gsub(/\n/,' ')
    specify 'Moab::FileInstance#datetime' do
      value = "Wed Apr 18 21:51:31 UTC 2012"
      @file_instance.datetime= value
      expect(@file_instance.datetime).to eq("2012-04-18T21:51:31Z")
       
      # attribute :datetime, Time, :on_save => Proc.new {|t| t.to_s}
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @v1_base_directory = @fixtures.join('data/jq937jp0017/v0001/content')
      @title_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
      @title_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/title.jpg')
      @v2_base_directory = @fixtures.join('data/jq937jp0017/v0002/content')
      @page1_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/page-1.jpg')
      @page1_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/page-1.jpg')

      @title_v1_instance = Moab::FileInstance.new.instance_from_file(@title_v1_pathname,@v1_base_directory)
      @title_v2_instance = Moab::FileInstance.new.instance_from_file(@title_v2_pathname,@v2_base_directory)
      @page1_v1_instance = Moab::FileInstance.new.instance_from_file(@page1_v1_pathname,@v1_base_directory)
      @page1_v2_instance = Moab::FileInstance.new.instance_from_file(@page1_v2_pathname,@v2_base_directory)
      
    end
    
    # Unit test for method: {Moab::FileInstance#instance_from_file}
    # Which returns: [Moab::FileInstance] Returns a file instance containing a physical file's' properties
    # For input parameters:
    # * pathname [Pathname] = The location of the physical file
    # * base_directory [Pathname] The full path used as the basis of the relative paths reported

    specify 'Moab::FileInstance#instance_from_file' do
      file_instance = Moab::FileInstance.new.instance_from_file(@title_v1_pathname,@v1_base_directory)
      expect(file_instance.path).to eq("title.jpg")
      expect(file_instance.datetime).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
       
      # def instance_from_file(pathname, base_directory)
      #   @path = pathname.realpath.relative_path_from(base_directory.realpath).to_s
      #   @datetime = pathname.mtime.iso8601
      #   self
      # end
    end
    
    # Unit test for method: {Moab::FileInstance#eql?}
    # Which returns: [Boolean] Returns true if self and other have the same path.
    # For input parameters:
    # * other [Moab::FileInstance] = The other file instance being compared to this instance 
    specify 'Moab::FileInstance#eql?' do
      expect(@title_v1_instance.eql?(@title_v2_instance)).to eq(true)
      expect(@page1_v1_instance.eql?(@page1_v2_instance)).to eq(true)
      expect(@title_v1_instance.eql?(@page1_v2_instance)).to eq(false)

      # def eql?(other)
      #   self.path == other.path
      # end
    end
    
    # Unit test for method: {Moab::FileInstance#==}
    # Which returns: [Boolean] Returns true if self and other have the same path.
    # For input parameters:
    # * other [Moab::FileInstance] = The other file instance being compared to this instance 
    specify 'Moab::FileInstance#==' do
      expect(@title_v1_instance == @title_v2_instance).to eq(true)
      expect(@page1_v1_instance == @page1_v2_instance).to eq(true)
      expect(@title_v1_instance == @page1_v2_instance).to eq(false)

      # def ==(other)
      #   eql?(other)
      # end
    end
    
    # Unit test for method: {Moab::FileInstance#hash}
    # Which returns: [Fixnum] Compute a hash-code for the path string.
    # For input parameters: (None)
    specify 'Moab::FileInstance#hash' do
      expect(@title_v1_instance.hash == @title_v2_instance.hash).to eq(true)
      expect(@page1_v1_instance.hash == @page1_v2_instance.hash).to eq(true)
      expect(@title_v1_instance.hash == @page1_v2_instance.hash).to eq(false)
       
      # def hash
      #   path.hash
      # end
    end
  
  end

end
