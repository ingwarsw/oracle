newproperty(:next) do
  include EasyType
  include EasyType::Mungers::Size

	desc "Size of the next autoextent"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('INCREMENT_BY').to_i
  end

  on_apply do
    "next #{resource[:next]}"
  end

end
