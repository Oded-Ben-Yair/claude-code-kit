.PHONY: install test run clean

install:
	pip install -r requirements.txt

test:
	python3 -m pytest test_server.py -v

run:
	bash start-with-adc.sh

clean:
	rm -rf __pycache__ .pytest_cache
	find . -name "*.pyc" -delete

check-adc:
	@gcloud auth application-default print-access-token > /dev/null 2>&1 \
		&& echo "ADC: OK" \
		|| echo "ADC: NOT CONFIGURED - run: gcloud auth application-default login"
