control 'SV-252154' do
  title 'Database objects (including but not limited to tables, indexes, storage, stored procedures, functions, triggers, links to software external to MongoDB, etc.) must be owned by database/DBMS principals authorized for ownership.'
  desc "Within the database, object ownership implies full privileges to the owned object, including the privilege to assign access to the owned objects to other subjects. Database functions and procedures can be coded using definer's rights. This allows anyone who utilizes the object to perform the actions if they were the owner. If not properly managed, this can lead to privileged actions being taken by unauthorized individuals.

Conversely, if critical tables or other objects rely on unauthorized owner accounts, these objects may be lost when an account is removed."
  desc 'check', 'Run the following command to get the roles from a MongoDB database.

For each database in MongoDB:

use database
db.getUsers()

If the output shows a role of "dbOwner", this is a finding.'
  desc 'fix', 'For each user where the role of dbOwner is found verify whether or not the user is authorized for this role on the resources listed.

This information will be found in the organizational or site-specific documentation.

If a user if found not authorized to have the role dbOwner the remove that role from the user with the 
db.revokeRolesFromUser() command

https://docs.mongodb.com/v4.4/reference/command/revokeRolesFromUser/'
  impact 0.5
  ref 'DPMS Target MongoDB Enterprise Advanced 4.x'
  tag check_id: 'C-55610r813842_chk'
  tag severity: 'medium'
  tag gid: 'V-252154'
  tag rid: 'SV-252154r813844_rule'
  tag stig_id: 'MD4X-00-002300'
  tag gtitle: 'SRG-APP-000133-DB-000200'
  tag fix_id: 'F-55560r813843_fix'
  tag 'documentable'
  tag cci: ['CCI-001499']
  tag nist: ['CM-5 (6)']

  check_command = "EJSON.stringify(db.getUsers())"

  input('mongo_dbs').each do |db_name|
    run_check_command = "mongosh mongodb://#{input('mongo_dba')}:#{input('mongo_dba_password')}@#{input('mongo_host')}:#{input('mongo_port')}/#{db_name}?authSource=admin --quiet --eval \"#{check_command}\""

    # run the command and parse the output as json
    users_output = json({command: run_check_command}).params

    users_output['users'].each do |user|
      # check if user is not a superuser
      unless input('mongo_superusers').include?(user['user'])
        # check each users role
        describe "User #{user['_id']} in database #{db_name}" do
          #collect all roles for user
          subject { user['roles'].map { |role| role['role'] } }
          it { should_not include 'dbOwner' }
        end
      end
    end
  end


end