require 'moab'

module Moab

  # A class to represent a version subdirectory within an object's home directory in preservation storage
  #
  # ====Data Model
  # * {StorageRepository} = represents a digital object repository storage node
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * <b>{StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory</b>
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageObjectVersion

    # @return [Integer] The ordinal version number
    attr_accessor :version_id

    # @return [String] The "v0001" directory name derived from the version id
    attr_accessor :version_name

    # @return [Pathname] The location of the version inside the home directory
    attr_accessor :version_pathname

    # @return [Pathname] The location of the object's home directory
    attr_accessor :storage_object

  # @param storage_object [StorageObject] The object representing the digital object's storage location
  # @param version_id [Integer,String] The ordinal version number or a string like 'v0003'
    def initialize(storage_object, version_id)
      if version_id.is_a?(Integer)
        @version_id = version_id
      elsif version_id.is_a?(String) and version_id.match /^v(\d+)$/
        @version_id = version_id.sub(/^v/,'').to_i
      else
        raise "version_id (#{version_id}) is not in a recognized format"
      end
      @version_name = StorageObject.version_dirname(@version_id)
      @version_pathname = storage_object.object_pathname.join(@version_name)
      @storage_object=storage_object
    end

    # @return [Boolean] true if the object version directory exists
    def exist?
      @version_pathname.exist?
    end

  # @param [String] file_category The category of file ('content', 'metadata', or 'manifest'))
  # @param [String] file_id The name of the file (path relative to base directory)
  # @return [FileSignature] signature of the specified file
    def find_signature(file_category, file_id)
      if file_category =~ /manifest/
        file_inventory('manifests').file_signature('manifests',file_id)
      else
        file_inventory('version').file_signature(file_category, file_id)
      end
    end

  # @param [String] file_category The category of file ('content', 'metadata', or 'manifest')
  # @param [String] file_id The name of the file (path relative to base directory)
  # @return [Pathname] Pathname object containing the full path for the specified file
    def find_filepath(file_category, file_id)
      this_version_filepath = file_pathname(file_category, file_id)
      return this_version_filepath if this_version_filepath.exist?
      raise "manifest file #{file_id} not found for #{@storage_object.digital_object_id} - #{@version_id}" if file_category == 'manifest'
      file_signature = file_inventory('version').file_signature(file_category, file_id)
      catalog_filepath = signature_catalog.catalog_filepath(file_signature)
      @storage_object.storage_filepath(catalog_filepath)
    end

  # @param [String] file_category The category of file ('content', 'metadata', or 'manifest')
  # @param [FileSignature] file_signature The signature of the file
  # @return [Pathname] Pathname object containing the full path for the specified file
    def find_filepath_using_signature(file_category, file_signature)
      catalog_filepath = signature_catalog.catalog_filepath(file_signature)
      @storage_object.storage_filepath(catalog_filepath)
    end

  # @param [String] file_category The category of file ('content', 'metadata', or 's')
  # @param [String] file_id The name of the file (path relative to base directory)
  # @return [Pathname] Pathname object containing this version's storage path for the specified file
    def file_pathname(file_category, file_id)
      file_category_pathname(file_category).join(file_id)
    end

  # @param [String] file_category The category of file ('content', 'metadata', or 's')
  # @return [Pathname] Pathname object containing this version's storage home for the specified file category
    def file_category_pathname(file_category)
      if file_category =~ /manifest/
        @version_pathname.join('manifests')
      else
        @version_pathname.join('data',file_category)
      end
    end

    # @api external
    # @param type [String] The type of inventory to return (version|additions|manifests)
    # @return [FileInventory] The file inventory of the specified type for this version
    # @see FileInventory#read_xml_file
    def file_inventory(type)
      if version_id > 0
        FileInventory.read_xml_file(@version_pathname.join('manifests'), type)
      else
        groups = ['content','metadata'].collect { |id| FileGroup.new(:group_id=>id)}
        FileInventory.new(
            :type=>'version',
            :digital_object_id => @storage_object.digital_object_id,
            :version_id => @version_id,
            :groups => groups
        )
      end
    end

    # @api external
    # @return [SignatureCatalog] The signature catalog of the digital object as of this version
    def signature_catalog
      if version_id > 0
        SignatureCatalog.read_xml_file(@version_pathname.join('manifests'))
      else
        SignatureCatalog.new(:digital_object_id => @storage_object.digital_object_id)
      end
    end

    # @api internal
    # @param bag_dir [Pathname,String] The location of the bag to be ingested
    # @return [void] Create the version subdirectory and move files into it
    def ingest_bag_data(bag_dir)
      raise "Version already exists: #{@version_pathname.to_s}" if @version_pathname.exist?
      @version_pathname.join('manifests').mkpath
      bag_dir=Pathname(bag_dir)
      ingest_dir(bag_dir.join('data'),@version_pathname.join('data'))
      ingest_file(bag_dir.join(FileInventory.xml_filename('version')),@version_pathname.join('manifests'))
      ingest_file(bag_dir.join(FileInventory.xml_filename('additions')),@version_pathname.join('manifests'))
    end

    # @api internal
    # @param source_dir [Pathname] The source location of the directory whose contents are to be ingested
    # @param target_dir [Pathname] The target location of the directory into which files are ingested
    # @param use_links [Boolean] If true, use hard links; if false, make copies
    # @return [void] recursively link or copy the source directory contents to the target directory
    def ingest_dir(source_dir, target_dir, use_links=true)
      raise "cannot copy - target already exists: #{target_dir.expand_path}" if target_dir.exist?
      target_dir.mkpath
      source_dir.children.each do |child|
        if child.directory?
          ingest_dir(child, target_dir.join(child.basename), use_links)
        else
          ingest_file(child, target_dir, use_links)
        end
      end
    end

    # @api internal
    # @param source_file [Pathname] The source location of the file to be ingested
    # @param target_dir [Pathname] The location of the directory in which to place the file
    # @param use_links [Boolean] If true, use hard links; if false, make copies
    # @return [void] link or copy the specified file from source location to the version directory
    def ingest_file(source_file, target_dir, use_links=true)
      if use_links
        FileUtils.link(source_file.to_s, target_dir.to_s) #, :force => true)
      else
        FileUtils.copy(source_file.to_s, target_dir.to_s)
      end
    end

    # @api internal
    # @param signature_catalog [SignatureCatalog] The current version's catalog
    # @param new_inventory [FileInventory] The new version's inventory
    # @return [void] Updates the catalog to include newly added files, then saves it to disk
    # @see SignatureCatalog#update
    def update_catalog(signature_catalog,new_inventory)
      signature_catalog.update(new_inventory, @version_pathname.join('data'))
      signature_catalog.write_xml_file(@version_pathname.join('manifests'))
    end

    # @api internal
    # @param old_inventory [FileInventory] The old version's inventory
    # @param new_inventory [FileInventory] The new version's inventory
    # @return [void] generate a file inventory differences report and save to disk
    def generate_differences_report(old_inventory,new_inventory)
      differences = FileInventoryDifference.new.compare(old_inventory, new_inventory)
      differences.write_xml_file(@version_pathname.join('manifests'))
    end

    # @api internal
    # @return [void] examine the version's directory and create/serialize a {FileInventory} containing the manifest files
    def generate_manifest_inventory
      manifest_inventory = FileInventory.new(
          :type=>'manifests',
          :digital_object_id=>@storage_object.digital_object_id,
          :version_id=>@version_id)
      manifest_inventory.groups << FileGroup.new(:group_id=>'manifests').group_from_directory(@version_pathname.join('manifests'), recursive=false)
      manifest_inventory.write_xml_file(@version_pathname.join('manifests'))
    end

    # @return [Boolean] return true if data files on disk are consistent with inventory files
    def verify_storage()
      self.verify_manifest_inventory &&
          self.verify_version_inventory &&
          self.verify_version_additions
    end

    # @param inventory [FileInventory] The file inventory containing the id to be verified
    # @return [Boolean] true if the id is correct, raise exception if there is an id mismatch
    def verify_version_id(inventory)
      if @storage_object.digital_object_id != inventory.digital_object_id
        raise "digital_object_id mismatch - expected: #{@storage_object.digital_object_id} - found: #{inventory.digital_object_id}"
      end
      if @version_id != inventory.version_id
        raise "version mismatch - expected: #{@version_id} - found: #{inventory.version_id}"
      end
      true
    end

    # @return [Boolean] return true if the manifest inventory matches the actual files
    def verify_manifest_inventory
      # the file to verify
      manifest_inventory = self.file_inventory('manifests')
      self.verify_version_id(manifest_inventory)
      manifest_group = manifest_inventory.group('manifests')
      raise "manifest group not found in #{file_pathname('manifests','manifestInventory.xml')}" if manifest_group.nil?
      # recapture the manifest signatures
      audit_group = FileGroup.new(:group_id=>'audit').group_from_directory(@version_pathname.join('manifests'), recursive=false)
      # the manifest inventory does not contain a file entry for itself
      audit_group.remove_file_having_path("manifestInventory.xml")
      group_difference = FileGroupDifference.new.compare_file_groups(manifest_group, audit_group)
      unless group_difference.difference_count == 0
        raise Moab::ValidationException, "#{group_difference.difference_count} differences found in manifests for version #{version_id}"
      end
      true
    end

    # @return [Boolean] returns true if files & signatures listed in version inventory can all be found
    def verify_version_inventory
      version_inventory = self.file_inventory('version')
      self.verify_version_id(version_inventory)
      signature_catalog =self.signature_catalog
      object_pathname = self.storage_object.object_pathname
      version_inventory.groups.each do |group|
        group.files.each do |file|
          file.instances.each do |instance|
            relative_path = File.join(group.group_id, instance.path)
            catalog_entry = signature_catalog.signature_hash[file.signature]
            storage_location = object_pathname.join(catalog_entry.storage_path)
            verify_file_location(relative_path,storage_location)
          end
        end
      end
      true
    end

    # @param file_id [String] The relative path of a file instance in a given version
    # @param [Pathname] file_location The storage location of the file
    # @return [Boolean] Return true if the file location exists, else raise an error
    def verify_file_location(file_id,file_location)
      if file_location.exist?
        true
      else
        raise "Storage location for '#{file_id.to_s}' not found at #{file_location.to_s}"
      end
    end

    # @return [Boolean] returns true if files in data folder match files listed in version addtions inventory
    def verify_version_additions
      version_additions = self.file_inventory('additions')
      self.verify_version_id(version_additions)
      FileInventoryDifference.new.verify_against_directory(version_additions,@version_pathname.join('data'))
    end

    # @param timestamp [Time] The time at which the deactivation was initiated.  Used to name the inactive directory
    # @return [null] Deactivate this object version by moving it to another directory.  (Used by restore operation)
    def deactivate(timestamp)
      if @version_pathname.exist?
        timestamp_pathname = @version_pathname.parent.join(timestamp.utc.iso8601.gsub(/[-:]/,''))
        timestamp_pathname.mkpath
        demote_pathame = timestamp_pathname.join(@version_pathname.basename)
        @version_pathname.rename(demote_pathame)
      end
    end

  end

end
