local proxy_stat = 0;

function check_stat(proxy_on_caller, proxy_off_caller)
    noctalia.runAsync(
        {"systemctl", "is-active", "--quiet", "dae.service"},
        function (result)
            -- activated
            if result.exitCode == 0 then
                proxy_stat = 1;
                barWidget.setGlyph("route");
                proxy_on_caller();
            else
            -- deactivated
                proxy_stat = 0;
                barWidget.setGlyph("route-off");
                proxy_off_caller();
            end
        end
    )
end

function update()
    noctalia.setUpdateInterval(60000)

    -- check if the dae service is running
    check_stat(nil, nil)
end

function onClick()
    check_stat(
        function ()
            noctalia.runAsync({ "daectl", "off" }, function(result)
                if result.exitCode == 0 then
                    noctalia.notify("dae.service Deactivated")
                else
                    noctalia.notify("Error when deactivating dae.service")
                end
                check_stat(nil, nil)
            end)
        end,

        function ()
            noctalia.runAsync({ "daectl", "on" }, function(result)
                if result.exitCode == 0 then
                    noctalia.notify("dae.service Activated")
                else
                    noctalia.notify("Error when activating dae.service")
                end
            end)
        end

    )
    
end

function onRightClick()
    noctalia.runAsync({ "daectl", "test"}, function(result)
        noctalia.notify(result.stdout)
    end)
end
