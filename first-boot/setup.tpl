:global ADMINUSER <admin-user>
:global ADMINPASS <admin-pass> 

#Create setup scripts from uploaded files
  
:global initScript do={
    :local fullname "$title.rsc"
    :local pFile [/file find where name=$fullname]

    if ($pFile != "") do={
        :local content [/file get $pFile contents]
        
        /system script
        add name="$title" source="$content"
        
        :put "Script ($title) created."

        /log info message="Script ($title) created."

        /file remove $pFile
    }
}

$initScript title="first-boot"

/log info message="Adding first-boot scheduler ..."

/system/scheduler 
add name="Boot" on-event="first-boot" interval=0s start-time=startup

/log info message="Adding new admin user with credentials ..."

/user
add name=$ADMINUSER password=$ADMINPASS group=full
remove admin

/log info message="Adding SSH public key for new admin user ..."

/user/ssh-keys
import public-key-file=mikrotik_rsa.pub user=$ADMINUSER

/file/remove [find where name="setup.rsc"]
