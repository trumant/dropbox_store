require 'spec_helper'

describe DropboxStore do

  context "message" do

    let(:name) { "name" }

    it "raises when asked to send a message that is unsupported" do
      expect { DropboxStore::message(nil, name) }.to raise_error(/not part of dropbox datastore api services/)
    end
  end
end
