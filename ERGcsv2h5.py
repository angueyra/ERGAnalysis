import pandas
import h5py

class espion_file:
    """Loader for erg ESPION CSV files into Python"""
    def __init__(self, filepath, filename, species):
        self.basedir = "/Users/angueyraaristjm/Documents/LiData/invivoERG/"
        self.filepath = filepath
        self.filename = filename
        self.savepath = self.basedir + self.filepath + "/"
        self.fullpath = self.savepath + self.filename + ".csv"
        self.species = species
        self.metadata = self.pull_metadata()
        self.datatable = self.pull_datatable()
        self.data = self.pull_data()
        self.HDF5remap()
    
    def pull_metadata(self):
        # pull and parse metadata information
        csvparams = pandas.read_csv(self.fullpath, header=1, usecols=[0, 1], nrows=10, low_memory=False)
        csvparams = csvparams.dropna()
        metadata = dict()
        intfields = ["Steps", "Channels"]
        datefields = ["DOB", "Date performed"]
        for i in range(1, 10):
            if csvparams.Parameter[i] in intfields:
                metadata[csvparams.Parameter[i]] = int(csvparams.Value[i])
            elif csvparams.Parameter[i] in datefields:
                metadata[csvparams.Parameter[i]] = pandas.to_datetime(csvparams.Value[i])
            elif csvparams.Parameter[i] == "Family Name":
                metadata["ID"] = csvparams.Value[i]
            else: 
                metadata[csvparams.Parameter[i]] = csvparams.Value[i]
        metadata['Species'] = self.species
        return metadata
                
    def pull_datatable(self):
        # pull datatable to parse data
        fullcsv = pandas.read_csv(self.fullpath, header=0, low_memory=False)
        if "Data Table" in fullcsv:
            #print("Data Table is Right")
            datatable = pandas.read_csv(self.fullpath, header=1, usecols=[3, 4, 5, 8], low_memory=False)
            datatable = datatable.dropna()
            datatable = datatable.astype(int)
        elif fullcsv.ix[12, 0] == "Data Table":
            #print("Data Table is Below")
            datatable = pandas.read_csv(self.fullpath, header=1, usecols=[0, 1, 2, 5], skiprows=13, low_memory=False)
            datatable = datatable.dropna()
            datatable = datatable.astype(int)
        elif fullcsv.ix[13, 0] == "Data Table":
            #print("Data Table is Below")
            datatable = pandas.read_csv(self.fullpath, header=1, usecols=[0, 1, 2, 5], skiprows=14, low_memory=False)
            datatable = datatable.dropna()
            datatable = datatable.astype(int)
        else:
            print("Did not find datatable")
        return datatable
    
    def pull_data(self):
        # parse data based on data table
        fullcsv = pandas.read_csv(self.fullpath, header=0, low_memory=False)
        data = dict()
        for step in range(self.metadata['Steps']):
            stepname = "Step" + str(step+1).zfill(2)
            # print(stepname)
            ch1start = self.datatable.Column[(self.datatable.Step==(int(step+1))) & (self.datatable.Chan==1)]
            ch2start = self.datatable.Column[(self.datatable.Step==(int(step+1))) & (self.datatable.Chan==2)]
            ntrials = self.datatable.Trials[(self.datatable.Step==(int(step+1))) & (self.datatable.Chan==1)]
            if len(ch1start)==1:
                #normally each step runs only once but if it's repeated, ESPION doubles the entries
                ch1start = int(ch1start)
                ch2start = int(ch2start-1)
                ntrials = int(ntrials)
                data[stepname] = self.espion_step(ch1start=ch1start, ch2start=ch2start, ntrials=ntrials, csvtable=fullcsv)
            elif len(ch1start.unique())==1:
                #found duplicates but all have the same column start
                ch1start = int(ch1start.unique())
                ch2start = int(ch2start.unique()-1)
                ntrials = int(ntrials.sum())
                data[stepname] = self.espion_step(ch1start=ch1start, ch2start=ch2start, ntrials=ntrials, csvtable=fullcsv)
        return data
    
    @staticmethod
    def espion_step(ch1start, ch2start, ntrials, csvtable):
        """Loader for a single erg ESPION step"""
        colstart = ch1start-1
        colend = colstart+1+(ntrials*2)
        currcsv = csvtable.ix[0:, colstart:colend].copy(deep=0)
        currcsv = currcsv.dropna().reset_index(drop=True)
        currcsv = currcsv.drop(0).reset_index(drop=True)
        colnames = []
        ch1cnt = 0
        ch2cnt = 0
        for i in range(0, len(currcsv.columns)):
            currcsv.ix[0:, i] = pandas.to_numeric(currcsv.ix[0:, i])
            if i == 0:
                colnames.append('t')
            elif 1 <= i < 1+ntrials:
                ch1cnt += 1
                colnames.append('L' + str(ch1cnt).zfill(2))
            elif 1+ntrials <= i < 1+(ntrials*2):
                ch2cnt += 1
                colnames.append('R' + str(ch2cnt).zfill(2))
        currcsv.columns = colnames
        currcsv = currcsv.divide(1000)
        csvoutput = currcsv.copy()
        return csvoutput

    def HDF5remap(self):
        dt = h5py.special_dtype(vlen=bytes)
        intfields = ["Steps", "Channels"]
        
        h5name = self.savepath + self.filename + ".h5"
        print('Saving h5 file...')
        with h5py.File(h5name, 'w') as hfile:
#             print('\tFrom datatable:')
            for col in self.datatable.columns:
                hfile.create_dataset(col.replace(' ','_'), data=self.datatable.get(col))
#                 print('\t\t'+ col)
#             print('\tFrom metadata:')
            for key in self.metadata:
                if key in intfields:
                    hfile.attrs.create(key.replace(' ','_'), data=self.metadata[key])
                else:
                    hfile.attrs.create(key.replace(' ','_'), data=str(self.metadata[key]), dtype=dt)
#                 print('\t\t' + key)
            # print('\tFrom data:')
            for step in self.data:
                group = hfile.create_group(step)
                group.create_dataset('t', data=self.data[step].filter(regex = 't'))
                group.create_dataset('L', data=self.data[step].filter(regex = 'L'))
                group.create_dataset('R', data=self.data[step].filter(regex = 'R'))
                # print('\t\t' + step)
        print('Saved to: ' + h5name + '\n')
        
# if __name__ == "__main__":
#     a = espion_file("20160928/20160928_wl05_2_eml1het", "20160928_wl05_2_01_iSscotdark", "Mouse")
