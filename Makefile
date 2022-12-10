SHELL := /bin/bash

run:
	bundle exec rerun --dir app --clear --quiet -- rackup -p 4567
