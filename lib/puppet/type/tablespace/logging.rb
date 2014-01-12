newproperty(:logging) do
  include SimpleResource

  desc "TODO: Add description"
  newvalues(:yes, :no)


  to_translate_to_resource do | raw_resource|
    case raw_resource['LOGGING']
    when 'LOGGING' then :yes
    when 'NOLOGGING' then :no
    else
      fail('Invalid Logging found in tablespace resource.')
    end
  end

  on_apply do
    if resource[:logging] == :yes
      "logging"
    end
  end

end

