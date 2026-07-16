@EndUserText.label: 'zabs_file_mass_po'
@Metadata.allowExtensions: true
define abstract entity zabs_file_mass_po
{
  mimeType      : abap.string(0);
  fileName      : abap.string(0);
  fileContent   : abap.rawstring(0);
  fileExtension : abap.string(0);
}
