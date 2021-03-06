
# PAMIĘTAJ O ZMIANIE POLITYKI URUCHAMIANIA SKRYPTÓW
# WIĘCEJ W README.TXT 


#Wszystkie zmienne programowe

#Wyczyszczenie zmiennej przechowującej zapisywany tekst
$tekst= ''; 

# Data format RRRR-MM-DD
$data = Get-date -format d;

# Pobiera datę i odejmuje od niej 7 dni 
$last_data = (get-date).AddDays(-7)

# Data format RRRR-MM-DD GG-MM-SS  
$datagodzina = get-date -format u; 

# Nazwa komputera pobiera się automatycznie
$name_computer = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name 

# Obiekt z informacjami o partycjach
$disk = get-WmiObject win32_logicaldisk -Computername $name_computer

# Zmienna przechowująca liczbę wszystkich partycji
$ilosc_dyskow = $disk.Count

# Użytkownik pobiera się automatycznie 
$uzytkownik = $env:username; 

# Pobiera datę i odejmuje od niej 7 dni 
$last_data = (get-date).AddDays(-7)

# Obiekty z błędami 
$app_error =Get-EventLog –LogName "Application" -After $last_data -EntryType Error
$sys_error = Get-EventLog –LogName "System" -After $last_data -EntryType Error

# Obiekt backup
$backup = Get-WBSummary

# Obiekt z dyskami fizycznymi
$Pdisk= Get-PhysicalDisk

# Obiekt z informacjami o baterii
$batt = Get-WmiObject -Class Win32_Battery

##############################################################


# Wszystkie zmienne użytkowe

# Lokalizacja gdzie będą zapisywać się pliki .txt
$lokalizacja_pliku = 'C:\Users\' + $uzytkownik + '\Desktop\Freedisk\log\' + $data +'.txt';

# Lokalizacja gdzie będą zapisywać się pliki .html
$lokalizacja_pliku_html = 'C:\Users\' + $uzytkownik + '\Desktop\Freedisk\podsumowanie.html';

# Lokalizacja gdzie zapisywać się będzie ostatni plik z błędami
$lokalizacja_pliku_bledow = 'C:\Users\' + $uzytkownik + '\Desktop\Freedisk\log\event-' + $data + '.html'

# E-mail od kogo
$EmailFrom = "testbielakamil@gmail.com" 

# Hasło do e-maila
$EmailPassword = "adminqwerty" 

# E-mail do kogo
$EmailTo = "biela.kamil@gmail.com"
  
# Nagłówek e-maila [nazwa komputera + ilość wolnego miejsa na dyskach]
$Subject = $name_computer  

# Serwer SMTP
$SMTPServer = "smtp.gmail.com"  

# TRUE jeśli ma sie zapisywać do pliku .txt FALSE jeśli nie
$are_file = $true; 

# TRUE jeśli maja sie wysyłać emaile FALSE jeśli nie
$are_email = $true; 

# TRUE jeśli ma sie zapisywac do pliku HTML, FALSE jeśli nie
$are_html = $true; 

# TRUE jeśli ma się zapisywać do pliku HTML, FALSE jeśli nie 
$are_error = $true;

# Lokalizacja plików których chcesz pobrać rozmiar
$file =  [array]''

# Nazwy wyświetlanej baz danych
$name_database = [array]'master','test','model';

# Nazwa bazy danej
$name_sql = "USER-HP\SQLEXPRESS";

# Nie wiem co to ale potrzebne
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");

# Obiekt SQL
$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $name_sql

# Obiekt z wszystkimi bazami danych
$dbs=$s.Databases

# Liczba wszystkich baz danych
$count_all_db = $name_database.count;

# Liczba baz danych
$count_db = $dbs.count;

# Ilość plików 
$count_file = $file.count;

# Ilość błędów w Aplikacjach
$count_app_error = $app_error.count

# Ilość błędów w Systemie
$count_sys_error = $sys_error.Count

##############################################################


# Funkcja zwraca tekst zapisywany do pliku o informacjach o bazie danej

function sql 
{
$sql='';

for ($x=0;$x -lt $count_db;$x++)
{
    for ($z=0;$z -lt $count_db;$z++)
    {
        if ($name_database[$z] -eq $dbs[$x].name)
        {
        $sql += "`n";
        $sql += 'Nazwa bazy: ' + $dbs[$x].name + "`n";
        $sql += 'Rozmiar bazy: ' + $dbs[$x].size + " MB `n";
        }
    }

}
return $sql;
}


##############################################################


# Funckja zwracająca tekst zapisywany do pliku o informacjach partycji

function disker 
{
$tekst += "Stan z " + $datagodzina.trimend("Z");
$tekst += "`n"; 

for ($x=0;$x -lt $ilosc_dyskow;$x++) # Pętla trwa tyle razy ile jest dysków
{
if ($disk[$x].Size)
{
$global:Subject += " Dysk " + $disk[$x].DeviceID.SubString(0,1) + ': ' + [math]::Round($disk[$x].FreeSpace/1073741824) + ' GB';
$tekst += "`n";
$tekst += "Litera partycji: " + $disk[$x].DeviceID.SubString(0,1) + "`n";
$tekst += "Całe miejsce: " + [math]::Round($disk[$x].Size/1073741824) + " GB `n";
$tekst += "Wolne miejsce: " + [math]::Round($disk[$x].FreeSpace/1073741824)+ "GB `n";
$procenty = [long]$disk[$x].FreeSpace / [long]$disk[$x].Size * 100
$procenty =[math]::Round($procenty)
$tekst += "Wolne jest: " + $procenty + "% `n";
}
}
return  $tekst;
}


##############################################################


# Funkcja zwracająca teskt zapisywany do pliku o informacjach o plikach

function file_size 
{
for ($x=0;$x -lt $count_file;$x++)
{
$stan = [bool]$file[$x];
if ($stan) { 
$size = (Get-Item $file[$x]).length;
$tekst += "`n";
$tekst += "Lokalizacja pliku: " + $file[$x] + " `n";
if ($size -lt 1024)
{
$tekst += "Rozmiar: " + $size + " B `n";
} elseif ($size -le 1048576) {
$tekst += "Rozmiar: " + [math]::Round($size/1024,2) + " KB `n";
} elseif ($size -ge 1073741824)
{
$tekst += "Rozmiar: " + [math]::Round($size/1073741824,5) + " GB `n";
} else
{
$tekst += "Rozmiar: " + [math]::Round($size/1048576,4) + " MB `n";
}
}
}
return $tekst;
}


##############################################################


# Funkcja zwracająca tekst html dodawany do tabeli 

function html
{
$tekst += "<tr>";
$tekst += "<td>" + $datagodzina.trimend("Z") + "</td>";

for ($x=0;$x -lt $ilosc_dyskow;$x++) # Pętla trwa tyle razy ile jest dysków
{
if ($disk[$x].Size)
{
$tekst += "<td class='disk'> " + $disk[$x].DeviceID.SubString(0,1) + "</td>";
$tekst += "<td class='disk'> " + [math]::Round($disk[$x].Size/1073741824) + " GB </td>";
$tekst += "<td class='disk'>  " + [math]::Round($disk[$x].FreeSpace/1073741824)+ " GB </td>";
$procenty = [long]$disk[$x].FreeSpace / [long]$disk[$x].Size * 100
$procenty =[math]::Round($procenty)
if ($procenty -lt 10)
{
$tekst += "<td class='red' class='disk'>  " + $procenty + "% </td>";
} else
{
$tekst += "<td class='disk'>  " + $procenty + "% </td>";
}
}
} 

for ($x=0;$x -lt $count_file;$x++)
{
$stan = [bool]$file[$x];
if ($stan) { 
$size = (Get-Item $file[$x]).length;
$tekst += "<td class='file'>" + $file[$x] + " </td>";
if ($size -lt 1024)
{
$tekst += "<td class='file'>" + $size + " B </td>";
} elseif ($size -le 1048576) {
$tekst += "<td class='file'>" + [math]::Round($size/1024,2) + " KB </td>";
} elseif ($size -ge 1073741824)
{
$tekst += "<td class='file'>" + [math]::Round($size/1073741824,5) + " GB </td>";
} else
{
$tekst += "<td class='file'>" + [math]::Round($size/1048576,4) + " MB </td>";
}
}
}


for ($x=0;$x -lt $count_db;$x++)
{
    for ($z=0;$z -lt $count_db;$z++)
    {
        if ($name_database[$z] -eq $dbs[$x].name)
        {
        $tekst += '<td class="sql"> ' + $dbs[$x].name + " </td>";
        $tekst += '<td class="sql"> ' + $dbs[$x].size + " MB </td>";
        }
    }


}


$tekst += "</tr>";
return  $tekst;
}


##############################################################

# Funkcja zwraca tekst z ilosciami błędów do e-maila

function email_errors 
{
$tekst = "`nLiczba znalezionych błędów w systemie: $count_sys_error `n"
$tekst += "Liczba znalezionych błędów w aplikacjach: $count_app_error `n"
return $tekst
}

##############################################################

# Funkcja zwraca tekst o baterii
function battery
{
$tekst ='';
 If ($batt.BatteryStatus -like '1') 
 {
    $tekst += 'Serwer działa na UPS od ' + $batt.TimeOnBattery + "`n"
 }
 elseif ($batt.BatteryStatus -like '2') 
 {
    $tekst += 'Serwer działa na prądzie.' + "`n"
 }
 return $tekst
 }

##############################################################

# Funkcja zwraca tekst o stanie dysku
function physical-disk 
{

ForEach ( $LDisk in $PDisk )

                {
                $tekst = "`n"
                $tekst += 'Nazwa dysku: ' + $LDisk.FriendlyName + "`n";

                $tekst += 'Stan dysku: ' + $LDisk.HealthStatus + "`n";

                $hdisk = $LDisk | Get-StorageReliabilityCounter | Select-Object ReadErrorsTotal, WriteErrorsTotal, Temperature, PowerOnHours| FL

                $tekst += 'Błędy odczytu: ' + $hdisk.ReadErrorsTotal + "`n"
                $tekst += 'Błędy zapisu: ' + $hdisk.WriteErrorsTotal + "`n"
                $tekst += 'Temperatura: ' + $hdisk.Temparature + "`n"
                $tekst += 'Godziny pracy: ' + $hdisk.PowerOnHours + "`n"
                }

return $tekst
}


##############################################################

# Funkcja zwraca tresc pliku z błędami 

function errors 
{
$tresc = ''
$tresc += 'Od daty: ' + $last_data + " do $data <br>"
$tresc += 'Liczba błędów w aplikacji: ' +  $count_app_error + "<br>"
$tresc += 'Liczba błędów w systemie: ' +  $count_sys_error + "<br>"
$tresc += "`n"
$tresc += '<h1> Błędy systemu</h1>';

for ($x=0;$x -lt $count_sys_error;$x++)
{
$tresc += '<fieldset>';
$tresc += '<legend>' + $sys_error[$x].Index + '</legend>';
$tresc += '<b> Data: </b>' + $sys_error[$x].TimeWritten + '<br />';
$tresc += '<b> Źródło: </b>' + $sys_error[$x].Source + '<br />';
$tresc += '<b> ID zdarzenia: </b>' + $sys_error[$x].EventID + '</br>';
$tresc += '<b> Wiadomość: </b>' +$sys_error[$x].Message + " `n";
$tresc += '</fieldset>';
}

$tresc += '<h1> Błędy aplikacji </h1>';
for ($x=0;$x -lt $count_app_error;$x++)
{
$tresc += '<fieldset>';
$tresc += '<legend>' + $app_error[$x].Index + '</legend>';
$tresc += '<b> Data: </b>' + $app_error[$x].TimeWritten + '<br />';
$tresc += '<b> Źródło: </b>' + $app_error[$x].Source + '<br />';
$tresc += '<b> ID zdarzenia: </b>' + $app_error[$x].EventID + '</br>';
$tresc += '<b> Wiadomość: </b>' +$app_error[$x].Message + " `n";
$tresc += '</fieldset>';
}

return $tresc;
}

##############################################################

# Funkcja zwracająca treść do e-maila o backupie
function last_backup
{
$tekst ="`n";

if ( $backup.NextBackupTime -eq '01/01/0001 00:00:00')
{
$tekst += 'Nie zaplanowano kolejnego backupu' + "`n"
} 
else 
{
$tekst += "Następny backup:" + $backup.NextBackupTime + "`n"
}

if ($backup.LastBackupTime -eq $backup.LastSuccessfulBackupTime)
{
#Sukces 
$tekst += "Ostatni backup:" + $backup.LastSuccessfulBackupTime + "`n"
$tekst += "Lokalizacja:" + $backup.LastSuccessfulBackupTargetPath + "`n"
} else
{
#Porażka
$tekst += "Ostatni backup nie przebiegł pomyślnie." + "`n" 
$tekst += "Ostatni udany backup:" + $backup.LastSuccessfulBackupTime + "`n"
$tekst += "Lokalizacja:" + $backup.LastSuccessfulBackupTargetPath + "`n"
$tekst += "Ostatni wykonywany backup:" + $backup.LastBackupTime + "`n"
$tekst += "Ostatni wykonaywany backup - lokalizacja:" + $backup.LastBackupTarget + "`n"
$tekst += "Treść niepowodzenia:" + $backup.DetailedMessage + "`n"
}
return $tekst;
}


##############################################################

# Uruchamiamy funkcje zwracające do zmiennych tekst zapisywany do plików/wysyłanych emailem i dodajemy go do siebie
$dysk =''
$dysk = disker;
disker | Export-Csv C:\Users\user\Desktop\text.txt
$pliki = file_size;
$sql = sql;
$warn = email_errors
$backup = last_backup
$hp_disk = physical-disk
$hp_battery = battery
$Body = $dysk +  $pliki + $sql + $warn + $backup + $hp_disk + $hp_battery;

# Sprawdzamy czy zmienna jest TRUE, jeśli tak zapisujemy do pliku .txt
if ($are_file)
{
$Body > $lokalizacja_pliku;  # Zapisanie na dysku
}

# Sprawdzamy czy zmienna jest TRUE, jeśli tak wysyłamy tekst emailem
if ($are_email)
{

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) # Port protokołu SSMTP
$SMTPClient.EnableSsl = $true ; # TRUE jesli ma użyć szyfrowania SSL, FALSE jesli nie 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPassword)
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}

# Czyścimy zmienna 
$tekst ='';

# Sprawdzamy czy zmienna jest TRUE, jeśli tak dodajemy do tabeli HTML
if ($are_html)
{
$html = html
$html >> $lokalizacja_pliku_html;  # Zapisanie na dysku
}

# Sprawdzamy czy zmienna jest TRUE, jeśli tak tworzymy plik z błędami 
if ($are_error)
{
$tresc_app_error = errors;
$tresc_app_error > $lokalizacja_pliku_bledow
}