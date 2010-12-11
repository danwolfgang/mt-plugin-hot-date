package HotDate::Plugin;

use strict;
use warnings;

sub config_template {
    my ($plugin, $param, $scope) = @_;
    my $html;

    # At the system level, an override switch exists. This switch causes
    # the selected options to be applied to all blogs.
    if ($scope eq 'system') {
        $html .= <<END_HTML;
<mtapp:Setting
    id="system_override"
    label="System Override">
    <input value="1" type="checkbox" name="system_override" id="system_override"<mt:If name="system_override"> checked="checked"</mt:If> /> 
    <label for="system_override"><__trans phrase="Click to override weblog-specific settings with the system-wide settings chosen below."></label>
</mtapp:Setting>
END_HTML
    }

    # Build the blog level plugin settings screen. If the system override
    # is enabled, just provide an explanation to the user; otherwise show
    # configuration options.
    my $config = $plugin->get_config_hash('system');
    if ( ($config->{'system_override'}) && ($scope =~ /blog/) ) {
        $html .= <<END_HTML;
<mtapp:Setting
    id="system_override_enabled"
    label="System Override Enabled">
    <__trans phrase="The System Override is enabled, preventing blog-level settings. To change <em>Hot Date</em>&rsquo;s settings, go to the System Overview and choose Plugins, then modify settings there.">
</mtapp:Setting>
END_HTML
    }
    else {
        $html .= <<END_HTML;
<mtapp:Setting
    id="minutes"
    label="Every Minute Counts">
    <input value="1" type="checkbox" name="minutes" id="minutes" <mt:If name="minutes">checked</mt:If> /> 
    <label for="minutes"><__trans phrase="When checked, shows every minute; when unchecked, rounds to the nearest 5 minute mark."></label>
</mtapp:Setting>
<mtapp:Setting
    id="seconds"
    label="Seconds Matter">
    <input value="1" type="checkbox" name="seconds" id="seconds" <mt:If name="seconds">checked="checked"</mt:If> /> 
    <label for="seconds"><__trans phrase="Show the &ldquo;seconds&rdquo; selection option."></label>
</mtapp:Setting>
END_HTML
    }
}

sub apply_default_settings {
    # Make system-level selections "trickle-down" to become default
    # options at the blog level.
    my ($plugin, $data, $scope_id) = @_;
    if ($scope_id eq 'system') {
        return $plugin->SUPER::apply_default_settings($data, $scope_id);
    } else {
        my $sys;
        for my $setting (@{$plugin->{'settings'}}) {
            my $key = $setting->[0];
            next if exists($data->{$key});
                # don't load system settings unless we need to
            $sys ||= $plugin->get_config_obj('system')->data;
            $data->{$key} = $sys->{$key};
        }
    }
}

sub _blog_config {
    # Grab the configuration settings. If the system override is enabled, 
    # then return the system-level settings. Otherwise return the blog-
    # level settings.
    my ($blog_id) = @_;
    my $plugin = MT->component('hotdate');
    my $sys = $plugin->get_config_hash('system');
    if ($sys->{'system_override'}) {
        return $sys;
    }
    else {
        return $plugin->get_config_hash('blog:' . $blog_id);
    }
}

sub update_param {
    my ($cb, $app, $param) = @_;
    my $blog_id = $app->param('blog_id');
    my $config = _blog_config($blog_id);
    $param->{seconds} = $config->{'seconds'};
    $param->{minutes} = $config->{'minutes'};
}

sub update_template {
    my ($cb, $app, $template) = @_;

    my $oldtext;
    # The date location changes based on how the edit entry page has been customized.
    if ($app->product_version >= 4.25 ) {
        $oldtext = q{<input class="entry-time" name="authored_on_time" value="<$mt:var name="authored_on_time" escape="html"$>" />};
    }
    else {
        $oldtext = q{<input class="entry-time" name="authored_on_time" tabindex="11" value="<$mt:var name="authored_on_time" escape="html"$>" />};
    }
    $oldtext = quotemeta($oldtext);
    
    my $newtext = <<'END_HTML';
    <a href="javascript:hd_current();" style="margin-left: 18px;"><img src="<mt:PluginStaticWebPath component="hotdate">now.png" width="16" height="16" border="0" alt="Update to current date/time" title="Update to current date/time" /></a>
    
    <br style="clear: both;" />
    
<div style="margin-top: 5px; width: 100%;">

    <select name="hd_time_hour" id="hd_time_hours" onchange="hd_assemble_date();" style="margin-right: 4px;">
        <option style="float: none;" value="1">1</option>
        <option style="float: none;" value="2">2</option>
        <option style="float: none;" value="3">3</option>
        <option style="float: none;" value="4">4</option>
        <option style="float: none;" value="5">5</option>
        <option style="float: none;" value="6">6</option>
        <option style="float: none;" value="7">7</option>
        <option style="float: none;" value="8">8</option>
        <option style="float: none;" value="9">9</option>
        <option style="float: none;" value="10">10</option>
        <option style="float: none;" value="11">11</option>
        <option style="float: none;" value="12">12</option>
    </select>
    <strong>:</strong>
    <select name="hd_time_min" id="hd_time_min" onchange="hd_assemble_date();" style="margin: 0 4px;">
        <option style="float: none;" value="00">00</option>
<mt:if name="minutes">
        <option style="float: none;" value="01">01</option>
        <option style="float: none;" value="02">02</option>
        <option style="float: none;" value="03">03</option>
        <option style="float: none;" value="04">04</option>
</mt:if>
        <option style="float: none;" value="05">05</option>
<mt:if name="minutes">
        <option style="float: none;" value="06">06</option>
        <option style="float: none;" value="07">07</option>
        <option style="float: none;" value="08">08</option>
        <option style="float: none;" value="09">09</option>
</mt:if>
        <option style="float: none;" value="10">10</option>
<mt:if name="minutes">
        <option style="float: none;" value="11">11</option>
        <option style="float: none;" value="12">12</option>
        <option style="float: none;" value="13">13</option>
        <option style="float: none;" value="14">14</option>
</mt:if>
        <option style="float: none;" value="15">15</option>
<mt:if name="minutes">
        <option style="float: none;" value="16">16</option>
        <option style="float: none;" value="17">17</option>
        <option style="float: none;" value="18">18</option>
        <option style="float: none;" value="19">19</option>
</mt:if>
        <option style="float: none;" value="20">20</option>
<mt:if name="minutes">
        <option style="float: none;" value="21">21</option>
        <option style="float: none;" value="22">22</option>
        <option style="float: none;" value="23">23</option>
        <option style="float: none;" value="24">24</option>
</mt:if>
        <option style="float: none;" value="25">25</option>
<mt:if name="minutes">
        <option style="float: none;" value="26">26</option>
        <option style="float: none;" value="27">27</option>
        <option style="float: none;" value="28">28</option>
        <option style="float: none;" value="29">29</option>
</mt:if>
        <option style="float: none;" value="30">30</option>
<mt:if name="minutes">
        <option style="float: none;" value="31">31</option>
        <option style="float: none;" value="32">32</option>
        <option style="float: none;" value="33">33</option>
        <option style="float: none;" value="34">34</option>
</mt:if>
        <option style="float: none;" value="35">35</option>
<mt:if name="minutes">
        <option style="float: none;" value="36">36</option>
        <option style="float: none;" value="37">37</option>
        <option style="float: none;" value="38">38</option>
        <option style="float: none;" value="39">39</option>
</mt:if>
        <option style="float: none;" value="40">40</option>
<mt:if name="minutes">
        <option style="float: none;" value="41">41</option>
        <option style="float: none;" value="42">42</option>
        <option style="float: none;" value="43">43</option>
        <option style="float: none;" value="44">44</option>
</mt:if>
        <option style="float: none;" value="45">45</option>
<mt:if name="minutes">
        <option style="float: none;" value="46">46</option>
        <option style="float: none;" value="47">47</option>
        <option style="float: none;" value="48">48</option>
        <option style="float: none;" value="49">49</option>
</mt:if>
        <option style="float: none;" value="50">50</option>
<mt:if name="minutes">
        <option style="float: none;" value="51">51</option>
        <option style="float: none;" value="52">52</option>
        <option style="float: none;" value="53">53</option>
        <option style="float: none;" value="54">54</option>
</mt:if>
        <option style="float: none;" value="55">55</option>
<mt:if name="minutes">
        <option style="float: none;" value="56">56</option>
        <option style="float: none;" value="57">57</option>
        <option style="float: none;" value="58">58</option>
        <option style="float: none;" value="59">59</option>
</mt:if>
    </select>
<mt:if name="seconds">
    <strong>:</strong>
    <select name="hd_time_sec" id="hd_time_sec" onchange="hd_assemble_date();" style="margin: 0 4px;">
        <option style="float: none;" value="00">00</option>
        <option style="float: none;" value="01">01</option>
        <option style="float: none;" value="02">02</option>
        <option style="float: none;" value="03">03</option>
        <option style="float: none;" value="04">04</option>
        <option style="float: none;" value="05">05</option>
        <option style="float: none;" value="06">06</option>
        <option style="float: none;" value="07">07</option>
        <option style="float: none;" value="08">08</option>
        <option style="float: none;" value="09">09</option>
        <option style="float: none;" value="10">10</option>
        <option style="float: none;" value="11">11</option>
        <option style="float: none;" value="12">12</option>
        <option style="float: none;" value="13">13</option>
        <option style="float: none;" value="14">14</option>
        <option style="float: none;" value="15">15</option>
        <option style="float: none;" value="16">16</option>
        <option style="float: none;" value="17">17</option>
        <option style="float: none;" value="18">18</option>
        <option style="float: none;" value="19">19</option>
        <option style="float: none;" value="20">20</option>
        <option style="float: none;" value="21">21</option>
        <option style="float: none;" value="22">22</option>
        <option style="float: none;" value="23">23</option>
        <option style="float: none;" value="24">24</option>
        <option style="float: none;" value="25">25</option>
        <option style="float: none;" value="26">26</option>
        <option style="float: none;" value="27">27</option>
        <option style="float: none;" value="28">28</option>
        <option style="float: none;" value="29">29</option>
        <option style="float: none;" value="30">30</option>
        <option style="float: none;" value="31">31</option>
        <option style="float: none;" value="32">32</option>
        <option style="float: none;" value="33">33</option>
        <option style="float: none;" value="34">34</option>
        <option style="float: none;" value="35">35</option>
        <option style="float: none;" value="36">36</option>
        <option style="float: none;" value="37">37</option>
        <option style="float: none;" value="38">38</option>
        <option style="float: none;" value="39">39</option>
        <option style="float: none;" value="40">40</option>
        <option style="float: none;" value="41">41</option>
        <option style="float: none;" value="42">42</option>
        <option style="float: none;" value="43">43</option>
        <option style="float: none;" value="44">44</option>
        <option style="float: none;" value="45">45</option>
        <option style="float: none;" value="46">46</option>
        <option style="float: none;" value="47">47</option>
        <option style="float: none;" value="48">48</option>
        <option style="float: none;" value="49">49</option>
        <option style="float: none;" value="50">50</option>
        <option style="float: none;" value="51">51</option>
        <option style="float: none;" value="52">52</option>
        <option style="float: none;" value="53">53</option>
        <option style="float: none;" value="54">54</option>
        <option style="float: none;" value="55">55</option>
        <option style="float: none;" value="56">56</option>
        <option style="float: none;" value="57">57</option>
        <option style="float: none;" value="58">58</option>
        <option style="float: none;" value="59">59</option>
    </select>
</mt:if>

    <select name="hd_time_ampm" id="hd_time_ampm" onchange="hd_assemble_date();" style="margin: 0 4px;">
        <option style="float: none;" value="am">am</option>
        <option style="float: none;" value="pm">pm</option>
    </select>
</div>

<input class="entry-time" name="authored_on_time" style="display: none; visibility: hidden;" value="<mt:Var name="authored_on_time" escape="html">" />

<script type="text/javascript"> 
    function hd_assemble_date() {
       // Calculate hour, based on am/pm
       var hd_hours = document.forms['entry_form'].hd_time_hours.value;
       hd_hours = parseInt(hd_hours);
       if (document.forms['entry_form'].hd_time_ampm.value == 'pm') {
           hd_hours += 12;
           if (hd_hours == 24) { hd_hours = '12'; } //for 12:00 pm
       }
       else { // am; still in the morning.
           if (hd_hours == 12) { hd_hours = '00'; } // for 12:00 am
           hd_hours += '';
           if (hd_hours.length != 2) { hd_hours = '0' + hd_hours; }
       }

       // Update the "real" date-time stamp field
       document.forms['entry_form'].authored_on_time.value = hd_hours + ':' + document.forms['entry_form'].hd_time_min.value + ':' + <mt:If name="seconds">document.forms['entry_form'].hd_time_sec.value<mt:Else>'00'</mt:If>;
    }

    function hd_grab() { 
        // Get the time from the authored_on_time field. Important, in case
        // the entry was already saved, we need the right time.
        var hd_now = document.forms['entry_form'].authored_on_time.value;
        var hd_hours = hd_now.substring(0, 2);
        hd_hours = parseInt(hd_hours, 10);
        if ( (hd_now.substring(3, 5) == 57) || (hd_now.substring(3, 5) == 58) || (hd_now.substring(3, 5) == 59) ) {
            hd_hours++; // if it's near the end of the hour, round up to the next hour
        }
        if (hd_hours >= 12) { //pm
            hd_hours -= 12;
            document.forms['entry_form'].hd_time_ampm.value = 'pm';
            if (hd_hours == 0) { hd_hours = '12'; } // for 12:00 pm
            hd_hours = hd_hours + '';
            document.forms['entry_form'].hd_time_hours.value = hd_hours;
        }
        else { // am
            if (hd_hours == 0) { // for 12:00 am
                hd_hours = '12';
            }
            document.forms['entry_form'].hd_time_ampm.value = 'am';
            document.forms['entry_form'].hd_time_hours.value = hd_hours;
        }
<mt:if name="minutes">
        document.forms['entry_form'].hd_time_min.value = hd_now.substring(3, 5);
<mt:else>
        var hd_round_min = hd_now.substring(4, 5); //grab the last digit of the minute space
        hd_round_min = parseInt(hd_round_min); 
        if ( (hd_round_min == 0) || (hd_round_min == 1) || (hd_round_min == 2) ) {
            document.forms['entry_form'].hd_time_min.value = hd_now.substring(3, 4) + '0';
        }
        else if ( (hd_round_min == 3) || (hd_round_min == 4) || (hd_round_min == 5) || (hd_round_min == 6) ) {
            document.forms['entry_form'].hd_time_min.value = hd_now.substring(3, 4) + '5';
        }
        else if ( (hd_round_min == 7) || (hd_round_min == 8) || (hd_round_min == 9) ) {
            var hd_updated_min = parseInt( hd_now.substring(3, 4) ) + 1;
            document.forms['entry_form'].hd_time_min.value = hd_updated_min + '0';
            if ( (hd_now.substring(3,5) == 57) || (hd_now.substring(3,5) == 58) || (hd_now.substring(3,5) == 59) ) {
                hd_new_hour = hd_hours + 1; // if it's near the end of the hour, round up to the next hour
                if (hd_new_hour == 13) {
                    hd_new_hour = '01';
                }
                document.forms['entry_form'].hd_time_hours.value = hd_new_hour
            }
        }
</mt:if>
<mt:if name="seconds">
        document.forms['entry_form'].hd_time_sec.value = hd_now.substring(6, 8);
</mt:if>
    }

    function hd_current() { // Get the current date and time.
        var hd_now = new Date;
        var hd_now_month = hd_now.getMonth() + 1;
        hd_now_month += ''; // Necessary so that the .length works
        if (hd_now_month.length != 2) { hd_now_month = '0' + hd_now_month; }
        var hd_now_date = hd_now.getDate();
        hd_now_date += ''; // Necessary so that the .length works
        if (hd_now_date.length != 2) { hd_now_date = '0' + hd_now_date; }
        document.forms['entry_form'].authored_on_date.value = hd_now.getFullYear() + '-' + hd_now_month + '-' + hd_now_date;
        var hd_current_hour = hd_now.getHours();
        if (hd_current_hour >= 12) {
           hd_current_hour -= 12;
           document.forms['entry_form'].hd_time_hours.value = hd_current_hour;
           document.forms['entry_form'].hd_time_ampm.value = 'pm';
        }
        else {
           document.forms['entry_form'].hd_time_hours.value = hd_current_hour;
           document.forms['entry_form'].hd_time_ampm.value = 'am';
        }
        var hd_current_min = hd_now.getMinutes(); // Calculate minutes
        hd_current_min += '';
        if (hd_current_min.length != 2) { hd_current_min = '0' + hd_current_min; }        
<mt:if name="minutes">
        document.forms['entry_form'].hd_time_min.value = hd_current_min;
<mt:else>
        var hd_round_min = hd_current_min.substring(1, 2); //grab the last digit of the minute space
        hd_round_min = parseInt(hd_round_min);
        if ( (hd_round_min == 0) || (hd_round_min == 1) || (hd_round_min == 2) ) {
            document.forms['entry_form'].hd_time_min.value = hd_current_min.substring(0, 1) + '0';
        }
        else if ( (hd_round_min == 3) || (hd_round_min == 4) || (hd_round_min == 5) || (hd_round_min == 6) ) {
            document.forms['entry_form'].hd_time_min.value = hd_current_min.substring(0, 1) + '5';
        }
        else if ( (hd_round_min == 7) || (hd_round_min == 8) || (hd_round_min == 9) ) {
            var hd_updated_min = parseInt( hd_current_min.substring(0, 1) ) + 1;
            document.forms['entry_form'].hd_time_min.value = hd_updated_min + '0';
            if ( (hd_current_min.substring(0,2) == 57) || (hd_current_min.substring(0,2) == 58) || (hd_current_min.substring(0,2) == 59) ) {
                hd_new_hour = hd_current_hour + 1; // if it's near the end of the hour, round up to the next hour
                if (hd_new_hour == 13) {
                    hd_new_hour = '01';
                }
                document.forms['entry_form'].hd_time_hours.value = hd_new_hour
            }
        }
</mt:if>
<mt:if name="seconds">
        var hd_current_sec = hd_now.getSeconds(); //Calculate seconds
        hd_current_sec += '';
        if (hd_current_sec.length != 2) { hd_current_sec = '0' + hd_current_sec; }        
        document.forms['entry_form'].hd_time_sec.value = hd_current_sec;
</mt:if>
        
        hd_assemble_date();
    }

    hd_grab();
</script>   

END_HTML

    $$template =~ s/$oldtext/$newtext/;
}

1;

__END__
