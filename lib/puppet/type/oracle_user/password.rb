newparam(:password) do
  include SimpleResource

  desc "The user's password"
  defaultto 'password'

  to_translate_to_resource do | raw_resource|
    raw_resource['PASSWORD']
  end

  on_apply do
    "identified by #{resource[:password]}"
  end

end
