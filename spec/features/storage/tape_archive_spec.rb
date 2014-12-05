require 'spec_helper'

describe "Tape archive" do
  #  In order to: preseve copies of digital objects to tape
  #  The application needs to: archive and retrieve version files

  before(:all) do

  end

  scenario "Set up policies regarding TSM archiving" do |example|
    # given: the TSM client system
    # action: set up a TSM policy domain, policy set, and management class
    # outcome: TSM storage managment policy

    skip("need to implement '#{example.description}'")
  end


  scenario "Archive a first version of a digital object" do
    # given: the version folder containing a version's files
    # action: do a TSM archive operation of the folder
    #       : verify that TSM archive exists (query archive)
    # outcome: copies of the version's files should be on tape
    #        : TSM log file and 'description' label and date for the archive

    skip("need to implement '#description' functionality")
  end

  scenario "Archive two more versions of the same digital object" do |example|
    # given: the version folders containing new versions files
    # action: do separate TSM archive operations for both versions' folders
    #       : verify that TSM archives exists (query archive)
    # outcome: copies of the versions' files should be on tape
    #        : TSM log file and 'description' label and date for the archive

    skip("need to implement '#{example.description}'")
  end

  scenario "Retrieve files of first version" do |example|
    # given: the 'description' label and date for the archive
    # action: retrieve the data from tape to a temp disk location
    # outcome: disk folder containing the version's files

    skip("need to implement '#{example.description}'")
  end

  scenario "Retrieve files of addtional versions" do |example|
    # given: the 'description' label and date for the archives
    # action: retrieve the data from tape to separate temp disk locations
    # outcome: disk folders containing the versions' files

    skip("need to implement '#{example.description}'")
  end

end
