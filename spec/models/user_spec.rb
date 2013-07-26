require 'spec_helper'

describe User do
  let(:omni_auth_hash) do 
    {
      "provider" => 'facebook',
      "uid" => '1234567',
      "info" => {
        "nickname" => 'jbloggs',
        "email" => 'joe@bloggs.com',
        "name" => 'Joe Bloggs',
        "first_name" => 'Joe',
        "last_name" => 'Bloggs',
        "image" => 'http://graph.facebook.com/1234567/picture?type=square',
        "urls" => { :Facebook => 'http://www.facebook.com/jbloggs' },
        "location" => 'Palo Alto, California',
        "verified" => true
      },
      "credentials" => {
        "token" => 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
        "expires_at" => 1321747205, # when the access token expires (it always will)
        "expires" => true # this will always be true
      },
      "extra" => {
        "raw_info" => {
          "id" => '1234567',
          "name" => 'Joe Bloggs',
          "first_name" => 'Joe',
          "last_name" => 'Bloggs',
          "link" => 'http://www.facebook.com/jbloggs',
          "username" => 'jbloggs',
          "location" => { :id => '123456789', :name => 'Palo Alto, California' },
          "gender" => 'male',
          "email" => 'joe@bloggs.com',
          "timezone" => -8,
          "locale" => 'en_US',
          "verified" => true,
          "updated_time" => '2011-11-11T06:21:03+0000'
        }
      }
    }
  end

  let(:user) do
    FactoryGirl.create(:user,
      name: "John Smith",
      email: "doubled@gmail.com",
      provider: "facebook",
      uid: "100006352424167",
      fb_access_token: "ABCDEF...",
      fb_access_expires_at: "1321747205"
    )
  end

  let(:start_time) {1374682390}
  let(:end_time) {1374754290}

  describe "METHOD 'create_with_omniauth'" do
    context "with valid details" do
      it "should add the user to the database" do
        User.count.should == 0
        user = User.create_with_omniauth(omni_auth_hash)
        user.should be_valid
        User.count.should == 1
      end
    end
  end

  describe "METHOD 'Facebook'" do
    context "when facebook token is valid" do
      before(:each) do
        omni_auth_hash["credentials"]["expires_at"] = (DateTime.now + 2.hours).to_i
      end

      context "when passed a block" do
        it 'should yield a Koala Favebook API instance to the block' do
          user = User.create_with_omniauth(omni_auth_hash)
          expect(user.facebook { |fb| fb }).to be_a_kind_of Koala::Facebook::API
        end
      end

      context "when no block is passed" do
        it 'should return a Koala Favebook API instance' do
          user = User.create_with_omniauth(omni_auth_hash)
          expect(user.facebook).to be_a_kind_of Koala::Facebook::API
        end
      end
    end

    context "when facebook token has expired" do
      it "should return nil" do
        user = User.create_with_omniauth(omni_auth_hash)
        expect(user.facebook { |fb| raise Koala::Facebook::APIError.new(403,"Invalid Token") }).to be_nil
      end
    end
  end

  describe "METHOD 'get_statuses'" do
    it "should get an array of statuses" do
      data_array = [
        {"status_id"=>1393634087524992, "time"=>1374754290, "uid"=>100006352424167}, 
        {"status_id"=>1393631927525208, "time"=>1374754241, "uid"=>100006352424167}, 
        {"status_id"=>1392923067596094, "time"=>1374682390, "uid"=>100006352424167}]
      Koala::Facebook::API.any_instance.should_receive(:fql_query).at_least(:once).and_return(data_array)
      user.get_statuses(start_time, end_time).should == data_array
    end
  end

  describe "METHOD 'get_location_posts'" do
    it "should get an array of statuses" do
      data_array = [
        {"post_id"=>1393634087524992, "timestamp"=>1374754290, "author_uid"=>100006352424167}, 
        {"post_id"=>1393631927525208, "timestamp"=>1374754241, "author_uid"=>100006352424167}, 
        {"post_id"=>1392923067596094, "timestamp"=>1374682390, "author_uid"=>100006352424167}]
      Koala::Facebook::API.any_instance.should_receive(:fql_query).at_least(:once).and_return(data_array)
      user.get_location_posts(start_time, end_time).should == data_array
    end
  end

end
