local proxy_stat = 0;

function check_stat(proxy_on_caller, proxy_off_caller)
    noctalia.runAsync(
        "systemctl is-active --quiet dae.service",
        function (result)
            -- activated
            if result.exitCode == 0 then
                proxy_stat = 1;
                if proxy_on_caller then
                    proxy_on_caller();
                end
            else
            -- deactivated
                proxy_stat = 0;
                if proxy_off_caller then
                    proxy_off_caller();
                end
            end
        end
    )
end

function update()
    noctalia.setUpdateInterval(60000)

    -- check if the dae service is running
    check_stat(
        function ()
            barWidget.setGlyph("route");
        end,
        
        function ()
            barWidget.setGlyph("route-off");
        end
)
end

function onClick()
    check_stat(
        function ()
            noctalia.runAsync("sudo systemctl stop dae.service", function(result)
                if result.exitCode == 0 then
                    barWidget.setGlyph("route-off");
                    noctalia.notify("dae.service Deactivated")
                else
                    noctalia.notify("Error when deactivating dae.service")
                end
            end)
        end,

        function ()
            noctalia.runAsync("sudo systemctl start dae.service", function(result)
                if result.exitCode == 0 then
                    barWidget.setGlyph("route");
                    noctalia.notify("dae.service Activated")
                else
                    noctalia.notify("Error when activating dae.service")
                end
            end)
        end

    )
    
end

function onRightClick()
    check_stat(
        function ()
            noctalia.runAsync(
            "t=$(curl -s -o /dev/null -w \"%{time_total}\" --max-time 10 google.com) && echo \"curl google.com returned within ${t}s\" || echo \"timeout\"", 
            function(result)
                noctalia.notify(result.stdout)
            end)
        end,

        nil
    )
end
