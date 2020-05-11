"use strict";

import React from "react";

async function fetchLevel(index) {
  const response = await fetch(`/levels/${index}.json`);
  const data = await response.json();
  return data;
}

export default function CodeView(props) {
  const { index } = props;
  const [level, setLevel] = React.useState(props.level);
  const [activeSource, setActiveSource] = React.useState(
    level ? Object.values(level.sources)[0] : null
  );
  React.useEffect(() => {
    if (level == null) {
      fetchLevel(index).then(level => {
        setLevel(level);
        setActiveSource(Object.values(level.sources)[0]);
      });
    }
  }, []);
  React.useEffect(() => {
    Prism.highlightAll();
  }, [activeSource]);

  if (!(level && activeSource)) {
    return <div />;
  }

  return (
    <div>
      <div class="bg-prism-bg rounded-t-lg p-4 mt-10 flex flex-row">
        <div class=" flex-grow">
          {Object.entries(level.sources).map(([key, source]) => {
            const active = source.name == activeSource.name;
            return (
              <button
                className={`rounded py-1 px-2 mr-2 mb-2 text-sm focus:outline-none ${
                  active
                    ? "bg-gray-600 text-gray-300"
                    : "text-gray-500 hover:bg-gray-700"
                }`}
                onClick={() => {
                  setActiveSource(source);
                }}
              >
                {source.basename}
              </button>
            );
          })}
        </div>
      </div>
      <pre class="rounded-b-lg">
        <code className={"language-" + activeSource.language}>
          {activeSource.code}
        </code>
      </pre>
    </div>
  );
}
