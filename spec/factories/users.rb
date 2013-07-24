FactoryGirl.define do
  factory :user do
    name "Dario D"
    email "doubled@gmail.com"
    provider "facebook"
    uid "100006352424167"
    fb_access_token "ABCDEF..."
    fb_access_expires_at "1321747205"
  end

end