#!/bin/bash
: ${INSTALL_YEAST_DATA:=1}
if [[ $INSTALL_YEAST_DATA -eq 1 ]]; then
	gmod_add_organism.pl --genus Saccharomyces --species cerevisiae --common_name yeast --comment '' --abbreviation 's.cer';

	gmod_gff3_preprocessor.pl --gff saccharomyces_cerevisiae.gff --nosplit --hasref && \
	cat saccharomyces_cerevisiae.gff.sorted > yeast.gff && \
	echo "##FASTA" >> yeast.gff && \
	cat saccharomyces_cerevisiae.gff.sorted.fasta >> yeast.gff && \

	# Cleanup GFF3 file
	sed -i 's/dbxref=NCBI:;//g' yeast.gff && \
	sed -i '/ARS_consensus_sequence/d' yeast.gff && \
	sed -i '/silent_mating_type_cassette_array/d' yeast.gff && \
	sed -i '/Y_region/d' yeast.gff && \
	sed -i '/W_region/d' yeast.gff && \
	sed -i '/Z1_region/d' yeast.gff && \
	sed -i '/X_region/d' yeast.gff && \
	sed -i '/Z2_region/d' yeast.gff && \
	sed -i '/intein_encoding_region/d' yeast.gff && \

	gmod_bulk_load_gff3.pl --organism yeast -g yeast.gff --recreate
fi
