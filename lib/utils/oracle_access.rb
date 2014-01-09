require 'tempfile'
require 'fileutils'
require 'csv'

module Utils
	module OracleAccess

		def self.included(parent)
			parent.extend(OracleAccess)
		end

	  ##
	  #
	  # Use this function to execute Oracle statements
	  #
	  # @param command [String] this is the commands to be given
	  #
	  #
		def sql( command, parameters = {})
			db_sid = 'O1VINFO'
			outFile = Tempfile.new([ 'output', '.csv' ])
			outFile.close
			FileUtils.chmod(0777, outFile.path)
			tmpFile = Tempfile.new([ 'sql', '.sql' ])
			tmpFile.puts("connect / as sysdba")
			tmpFile.puts("SET PAGES 0 EMB ON NEWP NONE")
			tmpFile.puts("SET NEWPAGE 0")
			tmpFile.puts("SET SPACE 0")
			tmpFile.puts("SET LINESIZE 32767")
			tmpFile.puts("SET ECHO OFF")
			tmpFile.puts("SET FEEDBACK OFF")
			tmpFile.puts("SET VERIFY OFF")
			tmpFile.puts("SET HEADING ON")
			tmpFile.puts("SET MARKUP HTML OFF SPOOL OFF")
			tmpFile.puts("SET COLSEP ','")
			tmpFile.puts("SPOOL #{outFile.path}")
			tmpFile.puts(command)
			tmpFile.puts('/')
			tmpFile.puts("spool off")
			tmpFile.puts('exit')
			tmpFile.close
			FileUtils.chmod(0555, tmpFile.path)
			output = `su - oracle -c 'export ORACLE_SID=#{db_sid};export ORAENV_ASK=NO;. oraenv;sqlplus -s /nolog @#{tmpFile.path}'`
			text = File.read(outFile.path)
			parse_data(text)
		end

		def parse_data(input)
			data = []
			headers = []
			csv_data = CSV.parse(input) do | row| 
				if headers.empty?
					headers = row.map {|header| header.strip }
				elsif row[0].include?('--')
					#do nothing
				else
					row.map!{|column| column.strip}
					values = headers.zip(row)
					data << Hash[*values.flatten]
				end
			end
			data
		end


	end
end