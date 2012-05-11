require 'spec_helper'

# Unit tests for class {Moab::StorageObject}
describe 'Moab::StorageObject' do
  
  describe '=========================== CLASS METHODS ===========================' do

    # Unit test for method: {Moab::StorageObject.version_dirname}
    # Which returns: [String] The directory name of the version, relative to the digital object home directory
    # For input parameters:
    # * version_id [Integer] = The version identifier of an object version 
    specify 'Moab::StorageObject.version_dirname' do
      Moab::StorageObject.version_dirname(1).should == "v0001"
      Moab::StorageObject.version_dirname(22).should == "v0022"
      Moab::StorageObject.version_dirname(333).should == "v0333"
      Moab::StorageObject.version_dirname(4444).should == "v4444"
      Moab::StorageObject.version_dirname(55555).should == "v55555"

      # def self.version_dirname(version_id)
      #   ("v%04d" % version_id)
      # end
    end
  
  end
  
  describe '=========================== CONSTRUCTOR ===========================' do

    before(:all) do
      @temp_ingests = @temp.join("ingests")
      @temp_object_dir = @temp_ingests.join(@obj)
    end

    after(:all) do
      @temp_ingests.rmtree if @temp_ingests.exist?
    end

    # Unit test for constructor: {Moab::StorageObject#initialize}
    # Which returns an instance of: [Moab::StorageObject]
    # For input parameters:
    # * object_id [String] = The digital object identifier 
    # * object_dir [Pathname, String] = The location of the object's storage home directory 
    specify 'Moab::StorageObject#initialize' do
       
      # test initialization with required parameters (if any)
      object_id = @obj
      storage_object = StorageObject.new(object_id, @temp_object_dir)
      storage_object.should be_instance_of(StorageObject)
      storage_object.digital_object_id.should == object_id
      storage_object.object_pathname.to_s.should include('temp/ingests/jq937jp0017')

      # def initialize(object_id, object_dir)
      #   @digital_object_id = object_id
      #   @object_pathname = Pathname.new(object_dir)
      #   initialize_storage unless @object_pathname.exist?
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      object_id = 'Test object_id' 
      @temp_ingests = @temp.join("ingests")
      @temp_object_dir = @temp_ingests.join(@obj)
      @storage_object = StorageObject.new(object_id, @temp_object_dir)
    end

    after(:all) do
      @temp_ingests.rmtree if @temp_ingests.exist?
    end
    
    # Unit test for attribute: {Moab::StorageObject#digital_object_id}
    # Which stores: [String] \@objectId = The digital object ID (druid)
    specify 'Moab::StorageObject#digital_object_id' do
      value = 'Test digital_object_id'
      @storage_object.digital_object_id= value
      @storage_object.digital_object_id.should == value
       
      # def digital_object_id=(value)
      #   @digital_object_id = value
      # end
       
      # def digital_object_id
      #   @digital_object_id
      # end
    end
    
    # Unit test for attribute: {Moab::StorageObject#object_pathname}
    # Which stores: [Pathname] The location of the object's storage home directory
    specify 'Moab::StorageObject#object_pathname' do
      value = @temp.join('object_pathname')
      @storage_object.object_pathname= value
      @storage_object.object_pathname.should == value
       
      # def object_pathname=(value)
      #   @object_pathname = value
      # end
       
      # def object_pathname
      #   @object_pathname
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @temp_ingests = @temp.join("ingests")
      @temp_ingests.rmtree if @temp_ingests.exist?
      @temp_object_dir = @temp_ingests.join(@obj)
      @storage_object = StorageObject.new(@obj,@temp_object_dir)
    end

    after(:all) do
      @temp_ingests.rmtree if @temp_ingests.exist?
    end

    # Unit test for method: {Moab::StorageObject#initialize_storage}
    # Which returns: [void] Create the directory for the digital object home unless it already exists
    # For input parameters: (None)
    specify 'Moab::StorageObject#initialize_storage' do
      @temp_object_dir.exist?.should == false
      @storage_object.initialize_storage()
      @temp_object_dir.exist?.should == true

      # def initialize_storage
      #   @object_pathname.mkpath
      # end
    end
    
    # Unit test for method: {Moab::StorageObject#ingest_bag}
    # Which returns: [void] Ingest a new object version contained in a bag into this objects storage area
    # For input parameters:
    # * bag_dir [Pathname, String] = The location of the bag to be ingested 
    specify 'Moab::StorageObject#ingest_bag' do
      #bag_dir = @temp.join('bag_dir')
      #current_version = mock('version_2')
      #signature_catalog = mock(SignatureCatalog.name)
      #new_version = mock('version_3')
      #new_inventory = mock(FileInventory.name)
      #@storage_object.should_receive(:current_version_id).and_return(2)
      #StorageObjectVersion.should_receive(:new).with(@storage_object,2).and_return(current_version)
      #StorageObjectVersion.should_receive(:new).with(@storage_object,3).and_return(new_version)
      #FileInventory.should_receive(:read_xml_file).with(bag_dir,'version').and_return(new_inventory)
      #@storage_object.should_receive(:validate_new_inventory).with(new_inventory)
      #new_version.should_receive(:ingest_bag_data).with(bag_dir)
      #current_version.should_receive(:signature_catalog).and_return(signature_catalog)
      #new_version.should_receive(:update_catalog).with(signature_catalog,new_inventory)
      #new_version.should_receive(:inventory_manifests)
      #@storage_object.ingest_bag(bag_dir)

      ingests_dir = @temp.join('ingests')
      ingests_dir.rmtree if ingests_dir.exist?
      (1..3).each do |version|
        object_dir = ingests_dir.join(@obj)
        object_dir.mkpath
        unless object_dir.join("v000#{version}").exist?
          bag_dir = @packages.join(@vname[version])
          StorageObject.new(@druid,object_dir).ingest_bag(bag_dir)
        end
      end

      files = Array.new
      ingests_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
          "ingests",
          "ingests/jq937jp0017",
          "ingests/jq937jp0017/v0001",
          "ingests/jq937jp0017/v0001/data",
          "ingests/jq937jp0017/v0001/data/content",
          "ingests/jq937jp0017/v0001/data/content/intro-1.jpg",
          "ingests/jq937jp0017/v0001/data/content/intro-2.jpg",
          "ingests/jq937jp0017/v0001/data/content/page-1.jpg",
          "ingests/jq937jp0017/v0001/data/content/page-2.jpg",
          "ingests/jq937jp0017/v0001/data/content/page-3.jpg",
          "ingests/jq937jp0017/v0001/data/content/title.jpg",
          "ingests/jq937jp0017/v0001/data/metadata",
          "ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml",
          "ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml",
          "ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml",
          "ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml",
          "ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml",
          "ingests/jq937jp0017/v0001/fileInventoryDifference.xml",
          "ingests/jq937jp0017/v0001/manifestInventory.xml",
          "ingests/jq937jp0017/v0001/signatureCatalog.xml",
          "ingests/jq937jp0017/v0001/versionAdditions.xml",
          "ingests/jq937jp0017/v0001/versionInventory.xml",
          "ingests/jq937jp0017/v0002",
          "ingests/jq937jp0017/v0002/data",
          "ingests/jq937jp0017/v0002/data/content",
          "ingests/jq937jp0017/v0002/data/content/page-1.jpg",
          "ingests/jq937jp0017/v0002/data/metadata",
          "ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml",
          "ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml",
          "ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml",
          "ingests/jq937jp0017/v0002/fileInventoryDifference.xml",
          "ingests/jq937jp0017/v0002/manifestInventory.xml",
          "ingests/jq937jp0017/v0002/signatureCatalog.xml",
          "ingests/jq937jp0017/v0002/versionAdditions.xml",
          "ingests/jq937jp0017/v0002/versionInventory.xml",
          "ingests/jq937jp0017/v0003",
          "ingests/jq937jp0017/v0003/data",
          "ingests/jq937jp0017/v0003/data/content",
          "ingests/jq937jp0017/v0003/data/content/page-2.jpg",
          "ingests/jq937jp0017/v0003/data/metadata",
          "ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml",
          "ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml",
          "ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml",
          "ingests/jq937jp0017/v0003/fileInventoryDifference.xml",
          "ingests/jq937jp0017/v0003/manifestInventory.xml",
          "ingests/jq937jp0017/v0003/signatureCatalog.xml",
          "ingests/jq937jp0017/v0003/versionAdditions.xml",
          "ingests/jq937jp0017/v0003/versionInventory.xml"
      ]

      ingests_dir.rmtree if ingests_dir.exist?
      object_dir = ingests_dir.join(@obj)
      object_dir.mkpath
      bag_dir = @temp.join('plain_bag')
      bag_dir.rmtree if bag_dir.exist?
      FileUtils.cp_r(@packages.join(@vname[1]).to_s,bag_dir.to_s,{:preserve => true})
      bag_dir.join('versionInventory.xml').delete
      bag_dir.join('versionAdditions.xml').delete
      bag_dir.join('versionInventory.xml').exist?.should == false
      bag_dir.join('versionAdditions.xml').exist?.should == false
      StorageObject.new(@druid,object_dir).ingest_bag(bag_dir)
      bag_dir.join('versionInventory.xml').exist?.should == true
      bag_dir.join('versionAdditions.xml').exist?.should == true

      ingests_dir.rmtree if ingests_dir.exist?

      # def ingest_bag(bag_dir)
      #   current_version = StorageObjectVersion.new(self,current_version_id)
      #   current_inventory = current_version.file_inventory('version')
      #   new_version = StorageObjectVersion.new(self,current_version_id + 1)
      #   if FileInventory.xml_pathname_exist?(bag_dir,'version')
      #   new_inventory = FileInventory.read_xml_file(bag_dir,'version')
      #   else
      #     new_inventory = versionize_bag(bag_dir,current_version,new_version)
      #   end
      #   validate_new_inventory(new_inventory)
      #   new_version.ingest_bag_data(bag_dir)
      #   new_version.update_catalog(current_version.signature_catalog,new_inventory)
      #   new_version.generate_differences_report(current_inventory,new_inventory)
      #   new_version.inventory_manifests
      # end
    end
    
    # Unit test for method: {Moab::StorageObject#versionize_bag}
    # Which returns: [FileInventory] The file inventory of the specified type for this version
    # For input parameters:
    # * bag_dir [Pathname] = The location of the bag to be ingested
    # * current_version [StorageObjectVersion] = The current latest version of the object
    # * new_version [StorageObjectVersion] = The version to be added
    specify 'Moab::StorageObject#versionize_bag' do
      bag_dir = @temp.join('plain_bag')
      bag_dir.rmtree if bag_dir.exist?
      FileUtils.cp_r(@packages.join(@vname[1]).to_s,bag_dir.to_s,{:preserve => true})
      bag_dir.join('versionInventory.xml').rename(bag_dir.join('vi.save'))
      bag_dir.join('versionAdditions.xml').rename(bag_dir.join('va.save'))
      current_version = @storage_object.storage_object_version(0)
      new_version = @storage_object.storage_object_version(1)
      new_inventory = @storage_object.versionize_bag(bag_dir, current_version, new_version)
      new_inventory.to_xml.gsub(/inventoryDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
        <fileInventory type="version" objectId="jq937jp0017" versionId="1" fileCount="11" byteCount="229690" blockCount="228">
          <fileGroup groupId="content" dataSource="/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/plain_bag/data/content" fileCount="6" byteCount="206432" blockCount="203">
            <file>
              <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178"/>
              <fileInstance path="intro-1.jpg" datetime="2012-03-26T14:20:35Z"/>
            </file>
            <file>
              <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"/>
              <fileInstance path="intro-2.jpg" datetime="2012-03-26T14:19:30Z"/>
            </file>
            <file>
              <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b"/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:59:14Z"/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
              <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
              <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
            </file>
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
              <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
            </file>
          </fileGroup>
          <fileGroup groupId="metadata" dataSource="/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/plain_bag/data/metadata" fileCount="5" byteCount="23258" blockCount="25">
            <file>
              <fileSignature size="1619" md5="b886db0d14508884150a916089da840f" sha1="b2328faaf25caf037cfc0263896ad707fc3a47a7"/>
              <fileInstance path="contentMetadata.xml" datetime="2012-03-28T14:04:24Z"/>
            </file>
            <file>
              <fileSignature size="3046" md5="a60bb487db6a1ceb5e0b5bb3cae2dfa2" sha1="edefc0e1d7cffd5bd3c7db6a393ab7632b70dc2d"/>
              <fileInstance path="descMetadata.xml" datetime="2012-03-26T17:43:49Z"/>
            </file>
            <file>
              <fileSignature size="12903" md5="ccb5bf2ae0c2c6ad0b89692fa1e10145" sha1="3badb0d06aef40f14e4664d2594c6060b9e9716b"/>
              <fileInstance path="identityMetadata.xml" datetime="2012-03-26T17:44:48Z"/>
            </file>
            <file>
              <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6"/>
              <fileInstance path="provenanceMetadata.xml" datetime="2012-03-26T17:46:44Z"/>
            </file>
            <file>
              <fileSignature size="384" md5="f16a2564fae2706a8c82cda6dccdb4d9" sha1="7aaf84f63a1db803d272352f03935d303f066560"/>
              <fileInstance path="versionMetadata.xml" datetime="2012-04-11T16:10:00Z"/>
            </file>
          </fileGroup>
        </fileInventory>
        EOF
      )
      bag_dir.join('versionAdditions.xml').read.gsub(/inventoryDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
        <fileInventory type="additions" objectId="jq937jp0017" versionId="1" fileCount="11" byteCount="229690" blockCount="228">
          <fileGroup groupId="content" dataSource="" fileCount="6" byteCount="206432" blockCount="203">
            <file>
              <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178"/>
              <fileInstance path="intro-1.jpg" datetime="2012-03-26T14:20:35Z"/>
            </file>
            <file>
              <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"/>
              <fileInstance path="intro-2.jpg" datetime="2012-03-26T14:19:30Z"/>
            </file>
            <file>
              <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b"/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:59:14Z"/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
              <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
              <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
            </file>
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
              <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
            </file>
          </fileGroup>
          <fileGroup groupId="metadata" dataSource="" fileCount="5" byteCount="23258" blockCount="25">
            <file>
              <fileSignature size="1619" md5="b886db0d14508884150a916089da840f" sha1="b2328faaf25caf037cfc0263896ad707fc3a47a7"/>
              <fileInstance path="contentMetadata.xml" datetime="2012-03-28T14:04:24Z"/>
            </file>
            <file>
              <fileSignature size="3046" md5="a60bb487db6a1ceb5e0b5bb3cae2dfa2" sha1="edefc0e1d7cffd5bd3c7db6a393ab7632b70dc2d"/>
              <fileInstance path="descMetadata.xml" datetime="2012-03-26T17:43:49Z"/>
            </file>
            <file>
              <fileSignature size="12903" md5="ccb5bf2ae0c2c6ad0b89692fa1e10145" sha1="3badb0d06aef40f14e4664d2594c6060b9e9716b"/>
              <fileInstance path="identityMetadata.xml" datetime="2012-03-26T17:44:48Z"/>
            </file>
            <file>
              <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6"/>
              <fileInstance path="provenanceMetadata.xml" datetime="2012-03-26T17:46:44Z"/>
            </file>
            <file>
              <fileSignature size="384" md5="f16a2564fae2706a8c82cda6dccdb4d9" sha1="7aaf84f63a1db803d272352f03935d303f066560"/>
              <fileInstance path="versionMetadata.xml" datetime="2012-04-11T16:10:00Z"/>
            </file>
          </fileGroup>
        </fileInventory>
      EOF
    )

      bag_dir.rmtree if bag_dir.exist?

      # def versionize_bag(bag_dir,current_version,new_version)
      #   new_inventory = FileInventory.new(:type=>'version',:digital_object_id=>object_id,:version=>new_version.version_id)
      #   new_inventory.inventory_from_directory(bag_dir.join('data'))
      #   new_inventory.write_xml_file(bag_dir)
      #   version_additions = current_version.signature_catalog.version_additions(new_inventory)
      #   version_additions.write_xml_file(bag_dir)
      #   new_inventory
      # end
    end

    # Unit test for method: {Moab::StorageObject#reconstruct_version}
    # Which returns: [void] Reconstruct an object version and package it in a bag for dissemination
    # For input parameters:
    # * version_id [Integer] = The version identifier of the object version to be disseminated 
    # * bag_dir [Pathname, String] = The location of the bag to be created 
    specify 'Moab::StorageObject#reconstruct_version' do
      reconstructs_dir = @temp.join('reconstructs')
      reconstructs_dir.rmtree if reconstructs_dir.exist?
      (1..3).each do |version|
        bag_dir = reconstructs_dir.join(@vname[version])
        unless bag_dir.exist?
          object_dir = @ingests.join(@obj)
          StorageObject.new(@druid,object_dir).reconstruct_version(version, bag_dir)
        end
      end

      files = Array.new
      reconstructs_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
          "reconstructs",
          "reconstructs/v1",
          "reconstructs/v1/bag-info.txt",
          "reconstructs/v1/bagit.txt",
          "reconstructs/v1/data",
          "reconstructs/v1/data/content",
          "reconstructs/v1/data/content/intro-1.jpg",
          "reconstructs/v1/data/content/intro-2.jpg",
          "reconstructs/v1/data/content/page-1.jpg",
          "reconstructs/v1/data/content/page-2.jpg",
          "reconstructs/v1/data/content/page-3.jpg",
          "reconstructs/v1/data/content/title.jpg",
          "reconstructs/v1/data/metadata",
          "reconstructs/v1/data/metadata/contentMetadata.xml",
          "reconstructs/v1/data/metadata/descMetadata.xml",
          "reconstructs/v1/data/metadata/identityMetadata.xml",
          "reconstructs/v1/data/metadata/provenanceMetadata.xml",
          "reconstructs/v1/data/metadata/versionMetadata.xml",
          "reconstructs/v1/manifest-md5.txt",
          "reconstructs/v1/manifest-sha1.txt",
          "reconstructs/v1/tagmanifest-md5.txt",
          "reconstructs/v1/tagmanifest-sha1.txt",
          "reconstructs/v1/versionInventory.xml",
          "reconstructs/v2",
          "reconstructs/v2/bag-info.txt",
          "reconstructs/v2/bagit.txt",
          "reconstructs/v2/data",
          "reconstructs/v2/data/content",
          "reconstructs/v2/data/content/page-1.jpg",
          "reconstructs/v2/data/content/page-2.jpg",
          "reconstructs/v2/data/content/page-3.jpg",
          "reconstructs/v2/data/content/title.jpg",
          "reconstructs/v2/data/metadata",
          "reconstructs/v2/data/metadata/contentMetadata.xml",
          "reconstructs/v2/data/metadata/descMetadata.xml",
          "reconstructs/v2/data/metadata/identityMetadata.xml",
          "reconstructs/v2/data/metadata/provenanceMetadata.xml",
          "reconstructs/v2/data/metadata/versionMetadata.xml",
          "reconstructs/v2/manifest-md5.txt",
          "reconstructs/v2/manifest-sha1.txt",
          "reconstructs/v2/tagmanifest-md5.txt",
          "reconstructs/v2/tagmanifest-sha1.txt",
          "reconstructs/v2/versionInventory.xml",
          "reconstructs/v3",
          "reconstructs/v3/bag-info.txt",
          "reconstructs/v3/bagit.txt",
          "reconstructs/v3/data",
          "reconstructs/v3/data/content",
          "reconstructs/v3/data/content/page-1.jpg",
          "reconstructs/v3/data/content/page-2.jpg",
          "reconstructs/v3/data/content/page-3.jpg",
          "reconstructs/v3/data/content/page-4.jpg",
          "reconstructs/v3/data/content/title.jpg",
          "reconstructs/v3/data/metadata",
          "reconstructs/v3/data/metadata/contentMetadata.xml",
          "reconstructs/v3/data/metadata/descMetadata.xml",
          "reconstructs/v3/data/metadata/identityMetadata.xml",
          "reconstructs/v3/data/metadata/provenanceMetadata.xml",
          "reconstructs/v3/data/metadata/versionMetadata.xml",
          "reconstructs/v3/manifest-md5.txt",
          "reconstructs/v3/manifest-sha1.txt",
          "reconstructs/v3/tagmanifest-md5.txt",
          "reconstructs/v3/tagmanifest-sha1.txt",
          "reconstructs/v3/versionInventory.xml"
      ]

      reconstructs_dir.rmtree if reconstructs_dir.exist?

      # def reconstruct_version(version_id, bag_dir)
      #   storage_version = StorageObjectVersion.new(self,version_id)
      #   version_inventory = storage_version.file_inventory('version')
      #   signature_catalog = storage_version.signature_catalog
      #   bagger = Bagger.new(version_inventory, signature_catalog, @object_pathname, bag_dir)
      #   bagger.fill_bag(:reconstructor)
      # end
    end
    
    # Unit test for method: {Moab::StorageObject#current_version_id}
    # Which returns: [Integer] The identifier of the latest version of this object
    # For input parameters: (None)
    specify 'Moab::StorageObject#current_version_id' do
      object_id = @obj
      object_dir = @ingests.join(@obj)
      storage_object = StorageObject.new(object_id, object_dir)
      storage_object.current_version_id().should == 3
       
      # def current_version_id
      #   return @current_version_id unless @current_version_id.nil?
      #   version_id = 0
      #   @object_pathname.children.each do |dirname|
      #     vnum = dirname.basename.to_s
      #     if vnum.match /^v(\d+)$/
      #       v = vnum[1..-1].to_i
      #       version_id = v > version_id ? v : version_id
      #     end
      #   end
      #   @current_version_id = version_id
      # end
    end
    
    # Unit test for method: {Moab::StorageObject#validate_new_inventory}
    # Which returns: [Boolean] Tests whether the new version number is one higher than the current version number
    # For input parameters:
    # * version_inventory [FileInventory] = The inventory of the object version to be ingested 
    specify 'Moab::StorageObject#validate_new_inventory' do
      object_id = @obj
      object_dir = @ingests.join(@obj)
      storage_object = StorageObject.new(object_id, object_dir)
      version_inventory_3 = mock(FileInventory.name+"3")
      version_inventory_3.should_receive(:version_id).twice.and_return(3)
      lambda{storage_object.validate_new_inventory(version_inventory_3)}.should raise_exception
      version_inventory_4 = mock(FileInventory.name+"4")
      version_inventory_4.should_receive(:version_id).and_return(4)
      storage_object.validate_new_inventory(version_inventory_4).should == true

      # def validate_new_inventory(version_inventory)
      #   if version_inventory.version_id != (current_version_id + 1)
      #     raise "version mismatch - current: #{current_version_id} new: #{version_inventory.version_id}"
      #   end
      #   true
      # end
    end

    # Unit test for method: {Moab::StorageObject#storage_object_version}
    # Which returns: [StorageObjectVersion] The representation of the subdirectory for the specified version
    # For input parameters:
    # * version_id [Integer] = The version to return.  If nil, return latest version
    specify 'Moab::StorageObject#storage_object_version' do
      storage_object = StorageObject.new(@obj,@ingests.join(@obj))

      version_2 = storage_object.storage_object_version(2)
      version_2.should be_instance_of(StorageObjectVersion)
      version_2.version_id.should == 2
      version_2.version_name.should == 'v0002'
      version_2.version_pathname.to_s.should =~ /ingests\/jq937jp0017\/v0002/

      version_latest = storage_object.storage_object_version()
      version_latest.should be_instance_of(StorageObjectVersion)
      version_latest.version_id.should == 3
      version_latest.version_name.should == 'v0003'
      version_latest.version_pathname.to_s.should =~ /ingests\/jq937jp0017\/v0003/

      # def storage_object_version(version_id=nil)
      #   if version_id
      #     StorageObjectVersion.new(self,version_id)
      #   else
      #     StorageObjectVersion.new(self,current_version_id)
      #   end
      # end
    end
  
  end

end
