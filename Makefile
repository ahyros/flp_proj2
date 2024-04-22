all:
	swipl -q -g main -o flp23-log -c flp23-log.pl

clean:
	rm flp23-log