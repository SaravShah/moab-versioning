require 'spec_helper'

# Unit tests for class {Moab::FileInventoryDifference}
describe 'Moab::FileInventoryDifference' do

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileInventoryDifference#initialize}
    # Which returns an instance of: [Moab::FileInventoryDifference]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileInventoryDifference#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_inventory_difference = FileInventoryDifference.new(opts)
      file_inventory_difference.should be_instance_of(FileInventoryDifference)
       
      # test initialization of arrays and hashes
      file_inventory_difference.group_differences.should be_kind_of(Array)
      file_inventory_difference.group_differences.size.should == 0

      # test initialization with options hash
      opts = OrderedHash.new
      opts[:digital_object_id] = 'Test digital_object_id'
      opts[:basis] = 'Test basis'
      opts[:other] = 'Test other'
      opts[:report_datetime] = "Apr 12 19:36:07 UTC 2012"
      file_inventory_difference = FileInventoryDifference.new(opts)
      file_inventory_difference.digital_object_id.should == opts[:digital_object_id]
      file_inventory_difference.difference_count.should == 0
      file_inventory_difference.basis.should == opts[:basis]
      file_inventory_difference.other.should == opts[:other]
      file_inventory_difference.report_datetime.should == "2012-04-12T19:36:07Z"

      # def initialize(opts={})
      #   @group_differences = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)

      @v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/versionInventory.xml')
      @v2_inventory = FileInventory.parse(@v2_inventory_pathname.read)

      opts = {}
      @file_inventory_difference = FileInventoryDifference.new(opts)
      @file_inventory_difference.compare(@v1_inventory,@v2_inventory)
      end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#digital_object_id}
    # Which stores: [String] The digital object ID (druid)
    specify 'Moab::FileInventoryDifference#digital_object_id' do
      @file_inventory_difference.digital_object_id.should == "druid:jq937jp0017"
       
      # attribute :digital_object_id, String, :tag => 'objectId'
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#difference_count}
    # Which stores: [Integer] the number of differences found between the two inventories that were compared (dynamically calculated)
    specify 'Moab::FileInventoryDifference#difference_count' do
      @file_inventory_difference.difference_count.should == 6
       
      # attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}
       
      # def difference_count
      #   @group_differences.inject(0) { |sum, group| sum + group.difference_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#basis}
    # Which stores: [String] Id information from the version inventory used as the basis for comparison
    specify 'Moab::FileInventoryDifference#basis' do
      @file_inventory_difference.basis.should == "v1"
       
      # attribute :basis, String
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#other}
    # Which stores: [String] Id information about the version inventory compared to the basis
    specify 'Moab::FileInventoryDifference#other' do
      @file_inventory_difference.other.should == "v2"

      # attribute :other, String
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#report_datetime}
    # Which stores: [Time] The datetime at which the report was run
    specify 'Moab::FileInventoryDifference#report_datetime' do
      Time.parse(@file_inventory_difference.report_datetime).should be_instance_of(Time)
      @file_inventory_difference.report_datetime = "Apr 12 19:36:07 UTC 2012"
      @file_inventory_difference.report_datetime.should == "2012-04-12T19:36:07Z"
       
      # def report_datetime=(datetime)
      #   @report_datetime=Time.input(datetime)
      # end
       
      # def report_datetime
      #   Time.output(@report_datetime)
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#group_differences}
    # Which stores: [Array<FileGroupDifference>] The set of data groups comprising the version
    specify 'Moab::FileInventoryDifference#group_differences' do
      @file_inventory_difference.group_differences.size.should == 2
       
      # has_many :group_differences, FileGroupDifference
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @v1_data_directory = @fixtures.join('data/jq937jp0017/v0001')
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
      @v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/versionInventory.xml')
      @v2_inventory = FileInventory.parse(@v2_inventory_pathname.read)
    end

    before (:each) do
      opts = {}
      @file_inventory_difference = FileInventoryDifference.new(opts)
    end
    
    # Unit test for method: {Moab::FileInventoryDifference#compare}
    # Which returns: [FileInventoryDifference] Returns a report showing the differences, if any, between two inventories
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison 
    # * other_inventory [FileInventory] = The inventory that is compared against the basis inventory 
      specify 'Moab::FileInventoryDifference#compare' do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      diff.should be_instance_of(FileInventoryDifference)
      diff.group_differences.size.should == 2
      diff.basis.should == "v1"
      diff.other.should == "v2"
      diff.difference_count.should == 6
      diff.digital_object_id.should == "druid:jq937jp0017"

      # def compare(basis_inventory, other_inventory)
      #   @digital_object_id ||= common_object_id(basis_inventory, other_inventory)
      #   @basis ||= basis_inventory.data_source
      #   @other ||= other_inventory.data_source
      #   @report_datetime = Time.now
      #   group_ids = basis_inventory.groups.keys | other_inventory.groups.keys
      #   group_ids.each do |group_id|
      #     basis_group = basis_inventory.groups.keyfind(group_id)
      #     other_group = other_inventory.groups.keyfind(group_id)
      #     unless (basis_group.nil? || other_group.nil?)
      #      @group_differences << FileGroupDifference.new.compare_file_groups(basis_group, other_group)
      #     end
      #   end
      #   self
      # end
      end

    specify 'Moab::FileInventoryDifference#group_difference' do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      group_diff = diff.group_difference("content")
      group_diff.group_id.should == "content"
    end
    
    # Unit test for method: {Moab::FileInventoryDifference#compare_with_directory}
    # Which returns: [FileInventoryDifference] Returns a report showing the differences, if any, between the manifest file and the contents of the data directory
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison
    # * data_directory [Pathname, String] = location of the directory to compare against the inventory
    # * group_id [String] = if specified, is used to set the group ID of the FileGroup created from the directory if nil, then the directory is assumed to contain both content and metadata subdirectories
    specify 'Moab::FileInventoryDifference#compare_with_directory' do
      diff = @file_inventory_difference.compare_with_directory(@v1_inventory,@v1_data_directory)
      diff.group_differences.size.should == 2
      diff.basis.should == "v1"
      diff.other.should include("data/jq937jp0017/v0001/content")
      diff.difference_count.should == 0
      diff.digital_object_id.should == "druid:jq937jp0017|"

      # def compare_with_directory(basis_inventory, data_directory, group_id=nil)
      #   directory_inventory = FileInventory.new(:type=>'directory').inventory_from_directory(data_directory,group_id)
      #   compare(basis_inventory, directory_inventory)
      #   self
      # end
    end
    
    # Unit test for method: {Moab::FileInventoryDifference#verify_against_directory}
    # Which returns: [Boolean] Returns true if the manifest file accurately represents the contents of the data directory
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison
    # * data_directory [Pathname, String] = location of the directory to compare against the inventory
    # * group_id [String] = if specified, is used to set the group ID of the FileGroup created from the directory if nil, then the directory is assumed to contain both content and metadata subdirectories
    specify 'Moab::FileInventoryDifference#verify_against_directory' do
      @file_inventory_difference.verify_against_directory(@v1_inventory,@v1_data_directory).should == true

      # def verify_against_directory(basis_inventory, data_directory, group_id=nil)
      #   compare_with_directory(basis_inventory, data_directory, group_id)
      #   difference_count == 0
      # end
    end
    
    # Unit test for method: {Moab::FileInventoryDifference#common_object_id}
    # Which returns: [String] Returns either the common digitial object ID, or a concatenation of both inventory's IDs
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison 
    # * other_inventory [FileInventory] = The inventory that is compared against the basis inventory 
    specify 'Moab::FileInventoryDifference#common_object_id' do
      basis_inventory=FileInventory.new(:digital_object_id=>"druid:aa111bb2222")
      other_inventory=FileInventory.new(:digital_object_id=>"druid:cc444dd5555")
      FileInventoryDifference.new.common_object_id(basis_inventory,other_inventory).should == "druid:aa111bb2222|druid:cc444dd5555"
      FileInventoryDifference.new.common_object_id(@v1_inventory,@v2_inventory).should == "druid:jq937jp0017"

      # def common_object_id(basis_inventory, other_inventory)
      #   if basis_inventory.digital_object_id != other_inventory.digital_object_id
      #     "#{basis_inventory.digital_object_id.to_s}|#{other_inventory.digital_object_id.to_s}"
      #   else
      #     basis_inventory.digital_object_id.to_s
      #   end
      # end
    end
    
  end

end
