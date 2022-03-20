'''
Step2, mcl would use 3 threads
python3 02.homolog_group_typing.py *.homolog.m6 all.swiss.GN.list > *.homolog.new
test for clm info
'''

import sys,pathlib,subprocess
import function
import subblastp
from glob import glob
from distutils.version import LooseVersion

def read_homologs(homologGroup_file):
    homologs={}
    countTmpGrp=1
    homologGroup_files = open(homologGroup_file)
    for line in homologGroup_files:
        if ',' in line:
            genesTmp=line.rstrip().split('\t')[-1].rstrip(',').split(',')
            homologs[line.rstrip().split('\t')[0]]=genesTmp
        else:
            genesTmp=line.rstrip().split('\t')
            homologs[countTmpGrp]=genesTmp
            countTmpGrp=countTmpGrp+1
    homologGroup_files.close()
    return homologs

def test_function(mcl_results_file,func_file):
    homologs=read_homologs(mcl_results_file)
    dictGN=function.read_GN(func_file)
    ratioFirstGN_dict={}
    for i in homologs.keys():
        dictGN_tmp=function.get_GN(homologs[i],dictGN)
        ratioFirstGN=function.count_GN(dictGN_tmp)
        ratioFirstGN_dict[i]=ratioFirstGN
    return (homologs,ratioFirstGN_dict)

def mcl_cluster(forHC_results_file,inflation_index):
    mcl_results_file=forHC_results_file+'.mcl'
    mcl_cmd=[bindir+'/mcl',forHC_results_file,'--abc','-I',inflation_index,'-te','3','-o',mcl_results_file]
    cmd_result=subprocess.run(mcl_cmd)
    if cmd_result.returncode != 0:
        print('MCL-WRONG!')
    return mcl_results_file

if __name__=='__main__':
    m6_file = sys.argv[1]
    func_file = sys.argv[2]

    bindir=str(pathlib.Path(__file__).resolve().parent)

    #bitScore -> edge weight
    solar_cmd=['perl',bindir+'/solar.pl','-a','prot2prot','-f','m8','-z',m6_file]
    solar_result=subprocess.run(solar_cmd,capture_output=True)
    solar_results=solar_result.stdout.decode('ascii').split('\n')
    solar_results_file=open(m6_file+'.raw','w')
    solar_results_file.write('\n'.join(solar_results))
    solar_results_file.close()
    solar_results_file=m6_file+'.raw'

    paired_cmd=['perl',bindir+'/filter_solar_paired_redundance.pl',solar_results_file]
    paired_result=subprocess.run(paired_cmd,capture_output=True)
    paired_results=paired_result.stdout.decode('ascii').split('\n')
    paired_results_file=open(m6_file+'.solar','w')
    paired_results_file.write('\n'.join(paired_results))
    paired_results_file.close()
    paired_results_file=m6_file+'.solar'

    forHC_cmd=['perl',bindir+'/bitScore_to_hclusterScore.pl',paired_results_file]
    forHC_result=subprocess.run(forHC_cmd,capture_output=True)
    forHC_results=forHC_result.stdout.decode('ascii').split('\n')
    forHC_results_file=open(m6_file+'.solar.forHC','w')
    forHC_results_file.write('\n'.join(forHC_results))
    forHC_results_file.close()
    cp_cmd=['cp',m6_file+'.solar.forHC',m6_file+'.solar.forHC.backup']
#    cp_cmd=['cp',m6_file+'.solar.forHC.backup',m6_file+'.solar.forHC']
    subprocess.run(cp_cmd)
    forHC_results_file=m6_file+'.solar.forHC'

    #test for clm info
    mci_results_file=forHC_results_file+'.mci'
    mcxload_cmd=[bindir+'/mcxload','-abc',forHC_results_file,'--stream-mirror','-o',mci_results_file]
    cmd_result=subprocess.run(mcxload_cmd)
    if cmd_result.returncode != 0:
        print('McxLoad-WRONG!')
    for i in ('1.1','1.2','1.6','2.0','2.4','2.8','3.2','3.6','4.0','4.4','4.8','5.0'):
        j=str(int(float(i)*10))
        mcl_cmd=[bindir+'/mcl',mci_results_file,'-I',i,'-te','3','-o',forHC_results_file+'.I'+j]
        cmd_result=subprocess.run(mcl_cmd)
        if cmd_result.returncode != 0:
            print('MclTest-WRONG!')
    clm_cmd=[bindir+'/clm','info',mci_results_file,forHC_results_file+'.I11',\
             forHC_results_file+'.I12', \
             forHC_results_file+'.I16', \
             forHC_results_file+'.I20', \
             forHC_results_file+'.I24', \
             forHC_results_file+'.I28', \
             forHC_results_file+'.I32', \
             forHC_results_file+'.I36', \
             forHC_results_file+'.I40', \
             forHC_results_file+'.I44', \
             forHC_results_file+'.I48', \
             forHC_results_file+'.I50'
            ]
    cmd_result=subprocess.run(clm_cmd,capture_output=True)
    cmd_results=cmd_result.stdout.decode('ascii').split('\n')
    cmd_result_file=open(m6_file+'.mcl.info','w')
    cmd_result_file.write('\n'.join(cmd_results))
    cmd_result_file.close()
    eff_mcl_inflaction={}
    for i in range(len(cmd_results)-1):
        if cmd_results[i] == '===':
            continue
        else:
            eff_mcl_inflaction[cmd_results[i].split()[3].split('I')[-1]] = cmd_results[i].split()[0].split('=')[1]
    inflaction_best=int(max(eff_mcl_inflaction.items(),key=lambda x:x[1])[0])

    #cluster by MCL
    homologNews=[]
    homologs=[]
    ratioFirstGN_dict={}
    #inflation_indexs=('1.1','2','3','4','5')
    inflation_indexs=['1.1']
    t9=str(round(inflaction_best/10,1))
    if inflaction_best > 11 and inflaction_best < 20:
        inflation_indexs=['1.1',t9]
    elif inflaction_best > 11 and inflaction_best < 30:
        inflation_indexs=['1.1','2',t9]
    elif inflaction_best > 11 and inflaction_best < 40:
        inflation_indexs=['1.1','2','3',t9]
    elif inflaction_best > 11 and inflaction_best <= 50:
        inflation_indexs=['1.1','2','3','4',t9]
        
    group_density=0
    group_density_rep=0
    group_inflation=0
    no_90identicalFunc_tag=0
    mcl_results_file=''
    for i in inflation_indexs:
        mcl_results_file=mcl_cluster(forHC_results_file,i)
        (homologs,ratioFirstGN_dict)=test_function(mcl_results_file,func_file)
        ##bring out the 100% group in low inflation's cluster
        homologs_100=[]
        homologs_left={}
        no_100identicalFunc_tag=0
        for j in homologs.keys():
            if ratioFirstGN_dict.get(j)[1] >= 100:
                homologNews.append(str(j)+'\t'+str(len(homologs[j]))+'\t'+ratioFirstGN_dict[j][0]+'('+str(ratioFirstGN_dict[j][1])+'%,'+str(i)+')'+'\t'+','.join(homologs[j]))
                homologs_100.extend(homologs[j])
            else:
                no_100identicalFunc_tag=1
                homologs_left[j]=homologs[j]
        homologs=homologs_left
        if no_100identicalFunc_tag == 0:
            break

#perl is faster for this task
#        forHC_results_files=open(forHC_results_file,'r')
#        forHC_results_files_new=open(forHC_results_file+'new','w')
#        for line in forHC_results_files:
#            lines=line.rstrip().split()
#            if lines[0] in homologs_100 or lines[1] in homologs_100:
#                continue
#            else:
#                forHC_results_files_new.write(line)
#        forHC_results_files.close()
#        forHC_results_files_new.close()
        filter_100_input=forHC_results_file+'.tmp'
        filter_100_input_file=open(filter_100_input,'w')
        filter_100_input_file.write(','.join(homologs_100))
        filter_100_input_file.close()
        filter_100_cmd=['perl',bindir+'/filter_100_genes.pl',forHC_results_file,filter_100_input]
        filter_100_result=subprocess.run(filter_100_cmd,capture_output=True)
        filter_100_results=filter_100_result.stdout.decode('ascii').split('\n')
        filter_100_results_file=open(forHC_results_file+'new','w')
        filter_100_results_file.write('\n'.join(filter_100_results))
        filter_100_results_file.close()

        mv_cmd=['mv',forHC_results_file+'new',forHC_results_file]
        subprocess.run(mv_cmd)
        ##

        all_ratio = [ratioFirstGN_dict.get(x)[1] for x in ratioFirstGN_dict.keys()]
        #up to 2 replicates of inflation, then shut down; now the 100IdenticalFunc test as above replaces this test
#        if group_density == len(all_ratio):
#            group_density_rep=group_density_rep+1
#            if group_density_rep > 2:
#                mcl_results_file=mcl_cluster(forHC_results_file,group_inflation)
#                (homologs,ratioFirstGN_dict)=test_function(mcl_results_file,func_file)
#                for j in homologs.keys():
#                    homologNews.append(str(j)+'\t'+str(len(homologs[j]))+'\t'+ratioFirstGN_dict[j][0]+'('+str(ratioFirstGN_dict[j][1])+'%,'+group_inflation+')'+'\t'+','.join(homologs[j]))
#        else:
#            group_inflation=i
#            group_density_rep=1
#        group_density=len(all_ratio)

        if min(all_ratio) < 90:
            no_90identicalFunc_tag=round(float(i),1)
            continue
        else:
            no_90identicalFunc_tag=0
            if homologs != {}:
                for j in homologs.keys():
                    homologNews.append(str(j)+'\t'+str(len(homologs[j]))+'\t'+str(ratioFirstGN_dict[j][0])+'('+str(ratioFirstGN_dict[j][1])+'%,'+str(i)+')'+'\t'+','.join(homologs[j]))
            break

    ##inflaction to 5 is still not OK, need to add them
    if no_90identicalFunc_tag >= 1 and homologs != {}:
            for i in homologs.keys():
                homologNews.append(str(i)+'\t'+str(len(homologs[i]))+'\t'+str(ratioFirstGN_dict[i][0])+'('+str(ratioFirstGN_dict[i][1])+'%,'+str(no_90identicalFunc_tag)+')'+'\t'+','.join(homologs[i]))

    ##print results
    print ('\n'.join(homologNews))
