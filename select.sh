#!/bin/bash

select var in "Hello" "World"
do
	break
done
echo "var is $var"
