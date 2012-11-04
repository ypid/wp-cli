<?php

namespace WP_CLI\Commands;

\WP_CLI::add_command( 'shell', new Shell_Command );

class Shell_Command extends \WP_CLI_Command {

	/**
	 * Open an interactive shell environment.
	 */
	public function __invoke() {
		$history_path = self::get_history_path();

		if ( function_exists( 'readline' ) ) {
			$repl = new REPL_Readline( $history_path );
		} else {
			$repl = new REPL_Basic( $history_path );
		}

		\WP_CLI::line( 'Type "exit" to close session.' );

		$non_expressions = array(
			'echo', 'global',
			'while', 'for', 'foreach', 'if', 'switch',
			'include', 'include\_once', 'require', 'require\_once'
		);
		$non_expressions = implode( '|', $non_expressions );

		while ( true ) {
			$line = $repl->read( 'wp> ' );
			$line = rtrim( $line, ';' ) . ';';

			if ( self::starts_with( $non_expressions, $line ) ) {
				eval( $line );
			} else {
				if ( self::starts_with( 'return', $line ) )
					$line = substr( $line, strlen( 'return' ) );

				$line = '$_ = ' . $line;

				eval( $line );

				\WP_CLI::line( var_export( $_, false ) );
			}
		}
	}

	private static function starts_with( $tokens, $line ) {
		return preg_match( "/^($tokens)[\(\s]+/", $line );
	}

	private static function get_history_path() {
		$data = getcwd() . get_current_user();

		return sys_get_temp_dir() . '/wp-cli-history-' . md5( $data );
	}
}


class REPL_Readline {

	function __construct( $history_path ) {
		$this->hist_path = $history_path;

		readline_read_history( $this->hist_path );

		register_shutdown_function( array( $this, 'save_history' ) );
	}

	function read( $prompt ) {
		$line = trim( readline( $prompt ) );
		if ( !empty( $line ) )
			readline_add_history( $line );

		return $line;
	}

	function save_history() {
		readline_write_history( $this->hist_path );
	}
}


class REPL_Basic {

	function read( $prompt ) {
		\WP_CLI::out( $prompt );
		return \cli\input();
	}
}
