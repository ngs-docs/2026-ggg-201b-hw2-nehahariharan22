
rule all:
    input:
        "SRR2584857_quast.1000000",
        "SRR2584857_annot.1000000",
        "SRR2584857_quast.3000000",
        "SRR2584857_annot.3000000",
        "SRR2584857_quast.5000000",
        "SRR2584857_annot.5000000"


rule subset_reads:
    input:
        r1 = "SRR2584857_1.fastq.gz",
        r2 = "SRR2584857_2.fastq.gz"
    output:
        r1 = "SRR2584857_1.sub.{sublines}.fastq",
        r2 = "SRR2584857_2.sub.{sublines}.fastq"
    shell:
        """
        zcat {input.r1} | head -n {wildcards.sublines} > {output.r1} || [[ $? -eq 141 ]]
        zcat {input.r2} | head -n {wildcards.sublines} > {output.r2} || [[ $? -eq 141 ]]
        """

rule assemble_subset:
    input:
        r1 = "SRR2584857_1.sub.{sublines}.fastq",
        r2 = "SRR2584857_2.sub.{sublines}.fastq"
    output:
        directory("SRR2584857_assembly.{sublines}")
    threads: 8
    conda: "megahit"
    shell:
        "megahit -1 {input.r1} -2 {input.r2} -f -t {threads} -o {output}"

rule get_contigs:
    input: "SRR2584857_assembly.{sublines}"
    output: "SRR2584857-assembly.{sublines}.fa"
    shell:
        "cp {input}/final.contigs.fa {output}"

rule quast_subset:
    input: "SRR2584857-assembly.{sublines}.fa"
    output: directory("SRR2584857_quast.{sublines}")
    threads: 4
    conda: "megahit"
    shell:
        "quast {input} -o {output} --threads {threads}"

rule prokka_subset:
    input: "SRR2584857-assembly.{sublines}.fa"
    output: directory("SRR2584857_annot.{sublines}")
    threads: 4
    conda: "prokka"
    shell:
        "prokka --outdir {output} --prefix subset_{wildcards.sublines} {input} --cpus {threads}"
