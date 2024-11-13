.PHONY:
covariate_data :
	code/run_covariate_data_extraction.R
characterizations : 
	code/run_characterization.R short_term && code/run_characterization.R medium_term && code/run_characterization.R any_time_prior
prepare_shiny :
	code/move_results_to_shiny.R
clean_shiny : 
	rm -rf shiny/data/*
clean_results :
	rm -rf results/*
clean_data :
	rm -rf data/*
clean_all :
	rm -rf shiny/data/* && rm -rf results/* && rm -rf data/*
