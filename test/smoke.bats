#!/usr/bin/env bats

@test "script prints help when missing args" {
	run bash ./rubicon_set_future_file_added_date.sh
	[ $status -ne 0 ]
}
