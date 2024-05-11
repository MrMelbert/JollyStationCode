import { useBackend } from '../backend';
import { Button, Dropdown, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';

export const WarfareEvent = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedNames } = data;

  const shellList = [
    '160mm Rocket Assisted AP',
    '160mm HE',
    '160mm Flak',
    '160mm Cluster AP',
    '460mm Rocket Assisted AP',
    '460mm Cluster HE',
    '460mm Cluster Flak',
    'WMD KAJARI',
  ];

  return (
    <Window title="Warfare Module" resizable theme="admin">
      <Window.Content scrollable>
        <Section title="Volley Configuration">
          <Flex
            direction="row"
            wrap="nowrap"
            align="center"
            justify="space-evenly"
          >
            <Flex.Item grow={1}>
              <Button.Confirm
                fluid
                icon="bomb"
                color="good"
                confirmContent="Confirm Shell Volley?"
                onClick={() => act('fireShells')}
                textAlign="center"
              >
                {'Fire Volley'}
              </Button.Confirm>
            </Flex.Item>
            <Flex.Item grow={1}>
              <Dropdown
                fluid
                icon="arrows-rotate"
                color="blue"
                selected="Change Firing Direction"
                noChevron
                nowrap
                options={['North', 'South', 'East', 'West']}
                onSelected={(value) =>
                  act('changeDirection', { direction: value })
                }
              />
            </Flex.Item>
          </Flex>
          <Section title="Shell Menu">
            <Flex
              direction="row"
              wrap="nowrap"
              align="start"
              justify="space-evenly"
            >
              <Flex.Item grow={1} mr={0.75}>
                <Section title="Loaded Shells">
                  <Stack vertical>
                    {selectedNames.map((currentShell) => (
                      <Stack.Item key={currentShell}>
                        <Stack fill>
                          <Stack.Item mt={0.25} textColor="label">
                            {currentShell}
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="minus"
                              color="bad"
                              onClick={() =>
                                act('removeShell', {
                                  selected: currentShell,
                                })
                              }
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Flex.Item>
              <Flex.Item grow={1}>
                <Section title="Available Shells">
                  <Stack vertical>
                    {shellList.map((currentShell) => (
                      <Stack.Item key={currentShell}>
                        <Stack fill>
                          <Stack.Item mt={0.25} textColor="label">
                            {currentShell}
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="plus"
                              color="good"
                              onClick={() =>
                                act('addShell', {
                                  selected: currentShell,
                                })
                              }
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
