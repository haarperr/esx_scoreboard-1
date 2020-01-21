var visable = false;

$(function () {
	window.addEventListener('message', function (event) {

		switch (event.data.action) {
			case 'toggle':
				if (visable) {
					$('#wrap').fadeOut();
				} else {
					$('#wrap').fadeIn();
				}

				visable = !visable;
				break;

			case 'close':
				$('#wrap').fadeOut();
				visable = false;
				break;

			case 'updatePlayerJobs':
				var jobs = event.data.jobs;

				$('#player_count').html(jobs.player_count);

				$('#ems').html(jobs.ems);
				$('#police').html(jobs.police);
				$('#mechanic').html(jobs.mechanic);
				$('#fire').html(jobs.fire);
				$('#rechter').html(jobs.rechter);
				$('#army').html(jobs.army);
				break;

			case 'updatePlayerList':
                $('#playerlist tr:gt(0)').remove();
                $('#playerlist').append(event.data.players);
                applyPingColor();
                //sortPlayerList();
                break;

            case 'updatePing':
                updatePing(event.data.players);
                applyPingColor();
                break;

            case 'updateServerInfo':
                if (event.data.maxPlayers) {
                    $('#max_players').html(event.data.maxPlayers);
                }

                if (event.data.uptime) {
                    $('#server_uptime').html(event.data.uptime);
                }

                if (event.data.playTime) {
                    $('#play_time').html(event.data.playTime);
                }

                break;

			default:
				console.log('esx_scoreboard: unknown action!');
				break;
		}
	}, false);
});

function applyPingColor() {
	$('#playerlist tr').each(function () {
		$(this).find('td:nth-child(2),td:nth-child(4)').each(function () {
			var ping = $(this).html();
			var color = 'lightgreen';

			if (ping >= 80) {
				color = 'red';
			}

			$(this).css('color', color);
			$(this).html(ping);
		});

	});
}

// Todo: not the best code
function updatePing(players) {
	jQuery.each(players, function (index, element) {
		if (element != null) {
			$('#playerlist tr:not(.heading)').each(function () {
					$(this).parent().find('td').eq(1).html(element.ping);
				});
		}
	});
}

function sortPlayerList() {
	var table = $('#playerlist'),
		rows = $('tr:not(.heading)', table);

	rows.sort(function(a, b) {
		var keyA = $('td', a).eq(1).html();
		var keyB = $('td', b).eq(1).html();

		return (keyA - keyB);
	});

	rows.each(function(index, row) {
		table.append(row);
	});
}