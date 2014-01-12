newproperty(:password) do
  include SimpleResource
  desc "The password"

  to_translate_to_resource do | raw_resource|
    ''
  end

 on_apply do
    "identified by #{self[:password]}"
  end

end

