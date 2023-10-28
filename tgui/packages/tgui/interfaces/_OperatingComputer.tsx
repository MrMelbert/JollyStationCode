import { BooleanLike } from 'common/react';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Button, Dimmer, LabeledList, NoticeBox, ProgressBar, Section, Tabs, NumberInput } from '../components';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'Brain',
    type: 'brain',
  },
];

type Surgery = {
  name: string;
  desc: string;
};

type Patient = {
  stat: string | null;
  statstate: string | null;
  blood_type: string | null;
  health: number | null;
  minHealth: number | null;
  maxHealth: number | null;
  bruteLoss: number | null;
  fireLoss: number | null;
  toxLoss: number | null;
  oxyLoss: number | null;
};

type Procedure = {
  name: string;
  next_step: string;
  alternative_step: string;
  chems_needed: string;
  alt_chems_needed: string;
};

type AnesthesiaStatus = {
  has_tank: BooleanLike;
  open: BooleanLike;
  failsafe: number;
  can_open_tank: BooleanLike;
};

type Data = {
  // TG vars
  surgeries: Surgery[];
  patient: Patient | null;
  procedures: Procedure[] | null;
  table: BooleanLike;
  // Maple vars
  anesthesia: AnesthesiaStatus | null;
};

export const _OperatingComputer = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);

  const { table, patient, procedures, surgeries, anesthesia } = data;

  return (
    <Window width={350} height={600}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Patient State
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Surgery Procedures
          </Tabs.Tab>
          <Tabs.Tab onClick={() => act('open_experiments')}>
            Experiments
          </Tabs.Tab>
        </Tabs>
        {tab === 1 &&
          (table ? (
            <PatientStateView
              patient={patient}
              procedures={procedures}
              anesthesia={anesthesia}
            />
          ) : (
            <NoticeBox>No Table Detected</NoticeBox>
          ))}
        {tab === 2 && <SurgeryProceduresView surgeries={surgeries} />}
      </Window.Content>
    </Window>
  );
};

const PatientStateView = (
  props: {
    patient: Patient | null;
    procedures: Procedure[] | null;
    anesthesia: AnesthesiaStatus | null;
  },
  context
) => {
  const { act, data } = useBackend<Patient>(context);
  const { patient, procedures, anesthesia } = props;

  const failsafe_enabled: boolean = anesthesia?.failsafe !== -1;

  const num_to_percent = (num: number) => {
    return Math.round(num * 10) / 10 + '%';
  };

  return (
    <>
      <Section title="Patient State">
        {patient ? (
          <LabeledList>
            <LabeledList.Item label="State" color={patient.statstate}>
              {patient.stat || 'No patient detected'}
            </LabeledList.Item>
            <LabeledList.Item label="Blood Type">
              {patient.blood_type || 'Unable to determine blood type'}
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={patient.health || 0}
                minValue={patient.minHealth || -100}
                maxValue={patient.maxHealth || 100}
                color={
                  patient.health !== null && patient.health >= 0
                    ? 'good'
                    : 'average'
                }>
                <AnimatedNumber
                  value={patient.health || 0}
                  format={num_to_percent}
                />
              </ProgressBar>
            </LabeledList.Item>
            {damageTypes.map((type) => (
              <LabeledList.Item key={type.type} label={type.label}>
                <ProgressBar
                  value={(patient[type.type] || 0) / (patient.maxHealth || 1)}
                  color="bad">
                  <AnimatedNumber
                    value={patient[type.type] || 0}
                    format={num_to_percent}
                  />
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : (
          'No Patient Detected'
        )}
      </Section>
      {anesthesia && (
        <Section title="Anesthesia">
          {!anesthesia.has_tank && (
            <Dimmer>No anesthesia tank attached.</Dimmer>
          )}
          <LabeledList>
            <LabeledList.Item label={'Control'}>
              <Button.Checkbox
                // Open is FALSE if we have no tank, likewise for can_open_tank
                disabled={!anesthesia.open && !anesthesia.can_open_tank}
                content={anesthesia.open ? 'Close Tank' : 'Open Tank'}
                color={anesthesia.open ? 'bad' : 'good'}
                icon="fan"
                onClick={() => act('toggle_anesthesia')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={'Safety'}>
              <Button.Checkbox
                checked={failsafe_enabled}
                tooltip={
                  failsafe_enabled
                    ? 'Automatically closes the attached tank if a set amount of time has elapsed.'
                    : ''
                }
                onClick={() =>
                  failsafe_enabled
                    ? act('disable_failsafe')
                    : act('set_failsafe', { new_failsafe_time: 360 })
                }
              />
              {failsafe_enabled && (
                <NumberInput
                  animated
                  unit="seconds"
                  width="100px"
                  minValue={5}
                  maxValue={600}
                  step={1}
                  value={anesthesia.failsafe}
                  disabled={!failsafe_enabled} // Just in case
                  onChange={(e, value) =>
                    act('set_failsafe', { new_failsafe_time: value })
                  }
                />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      {!procedures || procedures.length === 0 ? (
        <Section title={'Procedures'}>No Active Procedures</Section>
      ) : (
        procedures.map((procedure) => (
          <Section key={procedure.name} title={procedure.name}>
            <LabeledList>
              <LabeledList.Item label="Next Step">
                {procedure.next_step}
                {procedure.chems_needed && (
                  <>
                    <br />
                    <br />
                    <b>Required Chemicals:</b>
                    <br />
                    {procedure.chems_needed}
                  </>
                )}
              </LabeledList.Item>
              {procedure.alternative_step && (
                <LabeledList.Item label="Alternative Step">
                  {procedure.alternative_step}
                  {procedure.alt_chems_needed && (
                    <>
                      <br />
                      <br />
                      <b>Required Chemicals:</b>
                      <br />
                      {procedure.alt_chems_needed}
                    </>
                  )}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))
      )}
    </>
  );
};

const SurgeryProceduresView = (props: { surgeries: Surgery[] }, context) => {
  const { act, data } = useBackend(context);
  const { surgeries } = props;
  return (
    <Section title="Advanced Surgery Procedures">
      <Button
        icon="download"
        content="Sync Research Database"
        onClick={() => act('sync')}
      />
      {surgeries.map((surgery) => (
        <Section title={surgery.name} key={surgery.name}>
          {surgery.desc}
        </Section>
      ))}
    </Section>
  );
};
