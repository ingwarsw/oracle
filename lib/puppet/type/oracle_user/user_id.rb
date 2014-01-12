newproperty(:user_id) do
  include SimpleResource

  include SimpleResource::Validators::Integer
  include SimpleResource::Mungers::Integer

  desc "The user id"

  to_translate_to_resource do | raw_resource|
    raw_resource['USER_ID'].to_i
  end

  on_apply do
    "set user_id = #{resource[:user_id]}"
  end


end
