require 'moab_stanford'

module Stanford

  # An interface class to support access to SDR storage via a RESTful server
  class StorageServices < Moab::StorageServices

    # @return [StorageRepository] an instance of the interface to SDR storage
    @@repository = Stanford::StorageRepository.new

    # @param new_content_metadata [String] The content metadata to be compared to the base
    # @param object_id [String] The digital object identifier of the object whose version inventory is the basis of the comparison
    # @param subset [String] Speciifes which subset of files to list in the inventories extracted from the contentMetadata (all|preserve|publish|shelve)
    # @param base_version [Integer] The ID of the version whose inventory is the basis of, if nil use latest version
    # @return [FileInventoryDifference] The report of differences between the content metadata and the specified version
    def self.compare_cm_to_version(new_content_metadata, object_id, subset, base_version=nil)
      new_inventory = ContentInventory.new.inventory_from_cm(new_content_metadata, object_id, subset)
      begin
        base_version ||= self.current_version(object_id)
        base_cm_pathname = self.retrieve_file('metadata', 'contentMetadata.xml', object_id, base_version)
        base_inventory = ContentInventory.new.inventory_from_cm(base_cm_pathname.read, object_id, subset, base_version)
      rescue Moab::ObjectNotFoundException
        storage_object = StorageObject.new(object_id, 'dummy')
        base_version = StorageObjectVersion.new(storage_object,0)
        base_inventory = base_version.file_inventory('version')
      end
      FileInventoryDifference.new.compare(base_inventory, new_inventory)
    end

    # @param new_content_metadata [String] The content metadata to be compared to the current signtature catalog
    # @param object_id [String] The digital object identifier of the object whose signature catalog is to be used
    # @param version_id [Integer] The ID of the version whose signature catalog is to be used, if nil use latest version
    # @return [FileInventory] The versionAddtions report showing which files are new or modified in the content metadata
    def self.cm_version_additions(new_content_metadata, object_id, version_id=nil)
      new_inventory = ContentInventory.new.inventory_from_cm(new_content_metadata, object_id, 'preserve')
      begin
        version_id ||= self.current_version(object_id)
        storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
        signature_catalog = storage_object_version.signature_catalog
      rescue Moab::ObjectNotFoundException
        storage_object = StorageObject.new(object_id, 'dummy')
        base_version = StorageObjectVersion.new(storage_object,0)
        signature_catalog = base_version.signature_catalog
      end
      signature_catalog.version_additions(new_inventory)
    end

    def self.cm_remediate(object_id, version_id=nil)
      cm = self.retrieve_file('metadata', 'contentMetadata.xml', object_id, version_id)
      group = self.retrieve_file_group('content', object_id, version_id)
      ContentInventory.new.remediate_content_metadata(cm,group)
    end

  end

end