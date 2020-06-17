require 'write_xlsx'
require 'roo'
require 'fileutils'

# Chris Kirney, 2020-06-17 special thing for Meli
# This code reads in one spreadsheet and goes through each row.  If there is something in the row it outputs it in a
# second shpreadsheet in the same row but in the column next to the first populated cell.  It does this for all of the
# rest of the rows in the spreadsheet.  This was used to clean up a spreadsheet that had a bunch of extra columns in it
# in strange places.  It removed all of the extra columns.  This will not work properly if a given row in the
# spreadsheet is missing some information unless that missing information is at the end.  For example, say a spreadsheet
# had columns containing address, city, province and postal code with a bunch of random columns in between the
# information on each row.  This code will work if each row has the address, city and province on each row.  However,
# if a row had address, province and postal code then the city and postal code would not line up properly in the output
# spreadsheet.
in_file = './list_test.xlsx'
out_file = './list_out.xlsx'
workbook = WriteXLSX.new(out_file)
worksheet = workbook.add_worksheet(name = 'Table 1')
xlsx = Roo::Spreadsheet.open(in_file)
sheet = xlsx.sheet('Table 1')
for i in 1..sheet.last_row
  col = 0
  sheet.row(i).each do |in_val|
    unless in_val.nil?
      worksheet.write(i-1, col, in_val)
      col += 1
    end
  end
end
workbook.close