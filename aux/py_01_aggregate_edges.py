import sys, string

'''
Usage:

cd ~/Dropbox/research/Social\ Media\ and\ ICs
python code/py_01_aggregate_edges.py data/edges-aggregated.csv edges/*.csv


'''

outfile = sys.argv[1]
files = sys.argv[2:]

weights = {}

for filename in files:
    filehandle = open(filename, 'r')
    print filename
    for line in filehandle:
        # reduce edge to id
        edge = "|".join(line.rstrip().split(",")[0:4])
        # add +1 count (and create if index does not exist)
        weights[edge] = 1 + weights.get(edge, 0)  

# sort edge list
wts = weights.items()
wts.sort(cmp=lambda x,y: -cmp(x[1],y[1]))       

# print to file:
print outfile
fw = open(outfile, "w")
for edge,w in wts:
    linewrite = ",".join(edge.split("|")) + "," + str(w)
    print >> fw, linewrite
