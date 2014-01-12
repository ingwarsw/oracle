newproperty(:extent_management) do
  include SimpleResource

  desc "TODO: Give description"
  newvalues(:local, :dictionary)

  to_translate_to_resource do | raw_resource|
    raw_resource['EXTENT_MAN'].downcase.to_sym
  end

  on_apply do
    "extent management #{resource[:extent_management]}"
  end

end
