#
# Copyright (C) 2019 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

class AddCachedQuizLtiToSubmissions < ActiveRecord::Migration[5.1]
  tag :predeploy
  disable_ddl_transaction!

  def up
    add_column :submissions, :cached_quiz_lti, :boolean
    change_column_default(:submissions, :cached_quiz_lti, false)
    DataFixup::BackfillNulls.run(Submission, :cached_quiz_lti, default_value: false)
    Shard.current.database_server.unshackle do
      connection = Submission.connection
      connection.execute("VACUUM ANALYZE #{Submission.quoted_table_name}") if connection.open_transactions == 0
    end
    change_column_null(:submissions, :cached_quiz_lti, false)
  end

  def down
    remove_column :submissions, :cached_quiz_lti
  end
end
