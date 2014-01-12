require 'tempfile'
require 'fileutils'
require 'csv'
begin
	require 'ruby-debug'
	require 'pry'
rescue LoadError
	# do nothing 
end


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
			sid = parameters.fetch(:sid) {
				oratab.first[:sid] # For now if no sid is given always use the first one
			}
			Puppet.info "Executing: #{command} on database #{sid}"
			csv_string = execute_sql(command, :sid => sid)
			convert_csv_data_to_hash(csv_string)
		end

		private

		def oratab
			values = []
			File.open('/etc/oratab') do | oratab|
				oratab.each_line do | line|
					content = [:sid, :home, :start].zip(line.split(':'))
					values << Hash[content] unless comment?(line)
				end
			end
			values
		end

		def execute_sql(command, parameters)
			db_sid = parameters.fetch(:sid) { raise ArgumentError, "No sid specified"}
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
			tmpFile.puts("WHENEVER SQLERROR EXIT 2")
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
			raise ArgumentError, "Error executing puppet code, #{output}" if $? != 0
			File.read(outFile.path)
		end

		def convert_csv_data_to_hash(csv_data)
			data = []
			headers = []

			csv_data.split("\n").each do | row |
				columnized = row.split(',')
				columnized.map!{|column| column.strip}
				if headers.empty?
					headers = columnized
				elsif row.include?('----')
					#do nothing
				else
					values = headers.zip(columnized)
					data << Hash[values]
				end
			end
			data
		end

		def comment?(line)
			line.start_with?('#') || line.start_with?("\n")
		end


	end
end