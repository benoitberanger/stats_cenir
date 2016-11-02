# stats_cenir

To import the tables : 
  1. Go to https://secure.lixium.fr
  2. Log in MySQL
  3. Open grr_annulation table
  4. Go to the Export tab
  5. Select CSV format, delete column delemiter ", export all lines, then execute
  6. Open grr_entry table
  7. Go to the Export tab
  8. Select CSV format, delete column delemiter ", export all lines, then execute
  9. move the freshly downloaded grr_annulation.csv and grr_entry.csv to the Git folder
  
Now you can run the scripts preproc_annulations.m and preproc_entry.m. It will make all the computation and save the results into a .mat file

Finally, you can run plot_* to display the results
