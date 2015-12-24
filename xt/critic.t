use Test::Perl::Critic(-exclude => [
												'RequireFinalReturn',
												'RequireArgUnpacking',
                                    'ProhibitVersionStrings',
											   'ProhibitUnusedPrivateSubroutines',
											  ],
							  -severity => 3);
all_critic_ok();
